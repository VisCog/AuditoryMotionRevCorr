% plots individual filters and saves 

clear all;
close all;
clc;

% select group 
which_group = 2;

% gaussFilt
gaussFiltP = 0;
gaussSigma = 0.75;

flag_save = 0; % save filter?

%% Get data

subjects;

if which_group == 1
    group = EB;
elseif which_group == 2
    group = SC;
end
    
nsubs = length(group);
submat = 1:nsubs;

for which_sub = submat

    X = [];
    Xflip = [];
    response = [];
    direction = [];
    
    subid = group{which_sub};

    nt = 10;
    ns = 10;
    nblock = 1:6;
    pcorrect = .65; 

    data = [];

    for which_block = nblock

        filename = [subid '_aMotionRF_' num2str(which_block) '.mat'];
        load(filename);
        if which_block == 1
            data = [data; emat(201:end, :)];
        else
            data = [data; emat(1:end, :)];
        end
    end

    resp_id = 4;
    dir_id = 3;
    noise_id = 6:size(data,2);

    % raw stimuli 
    X_temp = data(:,noise_id);

    % indices
    LorR = logical(data(:,dir_id) - 1); % to make it 0 or 1
    direction_temp = LorR == 1; % select R
    response_temp = data(:,resp_id) == 1;

    % flip R to L
    Xflip_temp = flipDir(X_temp, direction_temp, nt, ns);

    X = [X; X_temp];
    Xflip = [Xflip; Xflip_temp];
    response = [response; response_temp];
    direction = [direction; direction_temp];

    ntrials = size(X,1); 
    direction = logical(direction);
    response = logical(response);

    %% P = <N[1,1](x,t)> - <N[1,0](x,t)> + <N[0,1](-x,t)> - <N[0,0](-x,t)>
    
    gaussFilt.yes = gaussFiltP;
    gaussFilt.sigma = gaussSigma;
    
    figure('Position', [0 0 1200 700]);

    % <N[1,1](x,t)> LeftCorrect
    subplot(3,5,1);
    staN11 = getSTA(X, and(~direction,response), nt, ns, gaussFilt);
    showSTA(staN11, {'LeftCorrect', 'space', 'time'});

    % <N[1,0](x,t)> LeftIncorrect
    subplot(3,5,6);
    staN10 = getSTA(X, and(~direction,~response), nt, ns, gaussFilt);
    showSTA(staN10, {'LeftIncorrect-respR', 'space', 'time'});

    % <N[0,1](x,t)> RightCorrect (not flipped, original)
    subplot(3,5,2);
    staN01 = getSTA(X, and(direction,response), nt, ns, gaussFilt);
    showSTA(staN01, {'RightCorrect', 'space', 'time'});

    % <N[0,0](-x,t)> RightIncorrect (not flipped, original)
    subplot(3,5,7);
    staN00 = getSTA(X, and(direction,~response), nt, ns, gaussFilt);
    showSTA(staN00, {'RightIncorrect-respL', 'space', 'time'});

    % <N[0,1](-x,t)> RightCorrect (flipped)
    subplot(3,5,3);
    staN01flip = getSTA(Xflip, and(direction,response), nt, ns, gaussFilt);
    showSTA(staN01flip, {'RightCorrect-flip', 'space', 'time'});

    % <N[0,0](-x,t)> RightIncorrect (flipped) 
    subplot(3,5,8);
    staN00flip = getSTA(Xflip, and(direction,~response), nt, ns, gaussFilt);
    showSTA(staN00flip, {'RightIncorrect-respL-flip', 'space', 'time'});

    % P = <N[1,1](x,t)> - <N[1,0](x,t)> + <N[0,1](-x,t)> - <N[0,0](-x,t)>
    P = staN11 - staN10 + staN01flip - staN00flip;
    subplot(3,5,[4,5,9,10]);
    showSTA(P, {'Derived Filter', 'space', 'time'});
    
    subplot(3,5,11);
    showSTA(staN11 + staN00, {'RespL', 'space', 'time'});
    
    subplot(3,5,12);
    showSTA(staN10 + staN01, {'RespR', 'space', 'time'});
    
    subplot(3,5,13);
    showSTA(staN11 + staN01flip, {'Correct', 'space', 'time'});
    
    subplot(3,5,14);
    showSTA(staN10 + staN00flip, {'Incorrect', 'space', 'time'});

    %% save

    if flag_save
        
        if gaussFiltP == 0
            savename = ['P_', subid];  
        elseif gaussFiltP == 1
            savename = ['P_', subid, '_smooth'];  
        end

        save(savename, 'P', 'staN11', 'staN10', 'staN01', 'staN00', 'staN01flip', 'staN00flip');
    end
    
end

