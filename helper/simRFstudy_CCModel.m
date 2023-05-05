function [threshold, P, Pcorr, Pincorr] = simRFstudy_CCModel(p, model, task, method)

% Simulate aMotionRF study to find threshold and filter (P).
% The experiment parameters match those used in the actual reverse
% correlation study. 

if ~exist('task','var') || (exist('task','var') && isempty(task))
    task = 'discriminate';
end

if ~exist('method', 'var') || (exist('method', 'var') && isempty(method))
    method = 'dot';
end

% define model
model_L = model;
model_R = fliplr(model);

noiseFac = p.noiseFac;

% quest
tGuess              = [2 2]; 
sdGuess             = 1;
pThreshold          = 0.65;
beta                = 3.5;
delta               = 0.02;
gamma               = 0.5;

stair1 = QuestCreate(tGuess(1),sdGuess,pThreshold,beta,delta,gamma);
stair2 = QuestCreate(tGuess(2),sdGuess,pThreshold,beta,delta,gamma);

% emat
nrepeat = 250*6; % nrepeat * 4 = total_trials 
nquest = 2;
ndir = 2; 
emat = expmat(1:nquest, 1:ndir);
emat = repmat(emat, nrepeat, 1);
[eseq, emat] = randseq(emat); 
[ex, ey] = size(emat); 
saveindex = ey + 1; 
total_trials = size(emat,1);

for seq = eseq

    which_trial = emat(seq,1);
    which_quest = emat(seq,2);
    which_direction = emat(seq,3); % 1: left / 2: right

    % get atten_factor 
    if which_quest == 1
        atten_factor = QuestQuantile(stair1);
    elseif which_quest == 2
        atten_factor = QuestQuantile(stair2);
    end
%     atten_factor = min(2, max(atten_factor, 0.001));

    % make external noise
    ext_noise = randn(p.nt, p.ns);
    ext_noise = ext_noise./max(abs(ext_noise(:))); 
    ext_noise = (ext_noise + 1)./2; 
    
    ext_noise2 = randn(p.nt, p.ns);
    ext_noise2 = ext_noise2./max(abs(ext_noise2(:))); 
    ext_noise2 = (ext_noise2 + 1)./2; 

    % make target
    which_model = 4;
    Models;
    target = MakeModel(p); 
    target(target<0) = 0; 
    target(1,10) = 0;
    target(10,1) = 0;
    target(2,9) = 0;
    target(9,2) = 0;
    target = target .* atten_factor; 
    
    if strcmp(task, 'discriminate')
        if which_direction == 2
            target = fliplr(target);
        end
    end
    
    % make stimulus (external noise + target)
    if strcmp(task, 'discriminate')
        stimulus = ext_noise + target; 
    elseif strcmp(task, 'detect')
        if which_direction == 1
            stimulus1 = ext_noise + target;
            stimulus2 = ext_noise2;
        elseif which_direction == 2
            stimulus1 = ext_noise;
            stimulus2 = ext_noise2 + target;
        end
    end
    
    % filter and decide
    if strcmp(method, 'dot')
        
        % response (dot)
        if strcmp(task, 'discriminate')
            resp_L = model_L .* stimulus;
            resp_R = model_R .* stimulus; 
        elseif strcmp(task, 'detect')
            resp_L = model_L .* stimulus1;
            resp_R = model_L .* stimulus2; 
        end
        L = sum(resp_L(:));
        R = sum(resp_R(:)); 
        
        % add internal noise
        L = L + noiseFac.*sqrt(abs(L)).*randn(1);
        R = R + noiseFac.*sqrt(abs(R)).*randn(1);

        % decision 
        if which_direction == 1 % left / stim 1 contained target
            if L > R
                correct = 1; 
            elseif L <= R
                correct = 0; 
            end
        elseif which_direction == 2
            if L >= R
                correct = 0; 
            elseif L < R
                correct = 1; 
            end
        end
        
    elseif strcmp(method, 'conv')
        
        % response (convolve)
        if strcmp(task, 'discriminate')
            resp_L = conv2(stimulus, model_L, 'same');
            resp_R = conv2(stimulus, model_R, 'same');
        elseif strcmp(task, 'detect')
            resp_L = conv2(stimulus1, model_L, 'same');
            resp_R = conv2(stimulus2, model_L, 'same');
        end
        
        % response (square)
        resp_L = resp_L.^2;
        resp_R = resp_R.^2;
        
        % add internal noise
        resp_L = resp_L + noiseFac.*sqrt(abs(resp_L)).*randn(size(resp_L));
        resp_R = resp_R + noiseFac.*sqrt(abs(resp_R)).*randn(size(resp_R));
        
        % subtract and integrate
        LRdiff = resp_L -  resp_R;
        LRdiff = sum(LRdiff(:));
        
%         % add internal noise
%         LRdiff = LRdiff + noiseFac.*sqrt(abs(LRdiff)).*randn(1);
        
        % decision
        if which_direction == 1
            if LRdiff > 0 
                correct = 1;
            else
                correct = 0;
            end
        elseif which_direction == 2
            if LRdiff < 0 
                correct = 1;
            else
                correct = 0;
            end
        end
        
    end

    % which external noise to save
    if strcmp(task, 'discriminate')
        save_ext_noise = ext_noise; 
    elseif strcmp(task, 'detect')
        if correct == 1
            if which_direction == 1
                save_ext_noise = ext_noise;
            elseif which_direction == 2
                save_ext_noise = ext_noise2; 
            end
        elseif correct == 0
            if which_direction == 1
                save_ext_noise = ext_noise2;
            elseif which_direction == 2
                save_ext_noise = ext_noise;
            end
        end
    end
    
    % record
    designmat2 = reshape(save_ext_noise, 1, p.nt*p.ns);
    emat(seq, saveindex) = correct;
    emat(seq, saveindex+1) = atten_factor;
    emat(seq, saveindex+2:saveindex+1+size(designmat2,2)) = designmat2; 

    % update Quest
    if which_quest == 1
        stair1 = QuestUpdate(stair1,atten_factor,correct); 
    elseif which_quest == 2
        stair2 = QuestUpdate(stair2,atten_factor,correct);
    end

end

emat = sortrows(emat);

% results

th1 = QuestMean(stair1);
th2 = QuestMean(stair2); 

threshold = (th1 + th2)/2; 

resp_id = 4;
dir_id = 3;
noise_id = 6:size(emat,2);

emat = emat(201:end,:);

% raw stimuli 
X = emat(:,noise_id);

% indices
LorR = logical(emat(:,dir_id) - 1); % to make it 0 or 1
direction = LorR == 1; % select R
response = emat(:,resp_id) == 1;

% flip R to L
if strcmp(task, 'discriminate')
    Xflip = flipDir(X, direction, p.nt, p.ns);
elseif strcmp(task, 'detect')
    Xflip = X;
end

direction = logical(direction);
response = logical(response);

gaussFilt.yes = 0;

staN11 = getSTA(X, and(~direction,response), p.nt, p.ns, gaussFilt);
staN10 = getSTA(X, and(~direction,~response), p.nt, p.ns, gaussFilt);
staN01flip = getSTA(Xflip, and(direction,response), p.nt, p.ns, gaussFilt);
staN00flip = getSTA(Xflip, and(direction,~response), p.nt, p.ns, gaussFilt);
P = staN11 - staN10 + staN01flip - staN00flip;
Pcorr = staN11 + staN01flip;
Pincorr = staN10 + staN00flip;

            
end