function [threshold, P, Pcorr, Pincorr] = simRFstudy_bayesIO(signal, model, k)

% simulate aMotionRF study to find threshold and filter (P). 
% decision made following a bayesian ideal observer. 

if sum(size(signal)==size(model)) ~= 2 
    error('error: signal and model should be same size');
end

% get nt and ns
[nt, ns] = size(signal); 

% define model (F)
F_L = model; 
F_R = fliplr(model); 

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
nrepeat             = 250*6; % nrepeat * 4 = total_trials 
nquest              = 2;
ndir                = 2; 
emat = expmat(1:nquest, 1:ndir);
emat = repmat(emat, nrepeat, 1);
[eseq, emat] = randseq(emat); 
[total_trials, ey] = size(emat); 
saveindex = ey + 1; 

for seq = eseq

    which_quest = emat(seq,2);
    which_direction = emat(seq,3); % 1: left / 2: right

    % get atten_factor 
    if which_quest == 1
        atten_factor = QuestQuantile(stair1);
    elseif which_quest == 2
        atten_factor = QuestQuantile(stair2);
    end
    atten_factor = max(atten_factor, 0.0000001);
    
    % make signal
    this_signal = signal .* atten_factor; 
    if which_direction == 2
        this_signal = fliplr(this_signal);
    end

    % make external noise
    ext_noise = randn(nt, ns);
    ext_noise = ext_noise./max(abs(ext_noise(:))); 
    ext_noise = (ext_noise + 1)./2; 

    % make stimulus
    stim = this_signal + ext_noise; 
    
    % make internal noise
    int_noise = k .* mean(stim(:)) .* randn(nt,ns); 
    
    % input
    input = stim + int_noise; 

    % template
    template_L = F_L;
    template_R = F_R; 

    % likelihood
    likeli_L = dot(input(:), template_L(:)); 
    likeli_R = dot(input(:), template_R(:)); 
    
    % decision 
    if likeli_L > likeli_R
        decision = 1; 
    else
        decision = 2;
    end

    % correct or not
    if which_direction == decision 
        correct = 1;
    else
        correct = 0;
    end

    % record
    designmat = reshape(ext_noise, 1, numel(ext_noise)); 
    emat(seq, saveindex) = correct;
    emat(seq, saveindex+1) = atten_factor;
    emat(seq, saveindex+2:saveindex+1+numel(designmat)) = designmat; 

    % update Quest
    if which_quest == 1
        stair1 = QuestUpdate(stair1,atten_factor,correct); 
    elseif which_quest == 2
        stair2 = QuestUpdate(stair2,atten_factor,correct);
    end

end % for seq

% housekeeping for results
emat = sortrows(emat); 
emat = emat(201:end,:);
resp_id = 4;
dir_id = 3;
noise_id = 6:size(emat,2);
quest_id = 2;
amp_id = 5;

% thresholds
th1 = QuestMean(stair1);
th2 = QuestMean(stair2); 
threshold = (th1 + th2)/2;

% raw stimuli 
X = emat(:,noise_id);

% indices
LorR = logical(emat(:,dir_id) - 1); % to make it 0 or 1
direction = LorR == 1; % select R
response = emat(:,resp_id) == 1;

% flip R to L
Xflip = flipDir(X, direction, nt, ns);

% filter
direction = logical(direction);
response = logical(response);
gaussFilt.yes = 0;
staN11 = getSTA(X, and(~direction,response), nt, ns, gaussFilt);
staN10 = getSTA(X, and(~direction,~response), nt, ns, gaussFilt);
staN01flip = getSTA(Xflip, and(direction,response), nt, ns, gaussFilt);
staN00flip = getSTA(Xflip, and(direction,~response), nt, ns, gaussFilt);
P = staN11 - staN10 + staN01flip - staN00flip;
Pcorr = staN11 + staN01flip;
Pincorr = staN10 + staN00flip;

end