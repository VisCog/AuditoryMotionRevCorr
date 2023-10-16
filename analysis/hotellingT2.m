% paired-samples hotelling T2 test (based on Abbey & Eckstein 2002)
clear all;
close all;
clc;

% housekeeing
subjects;
nt = 10;
ns = 10; 
blocks = 1:6; 

% aggregate data 
for which_group = 1:2
        
    if which_group == 1
        group = EB;
    elseif which_group == 2
        group = SC;
    end

    nsubs = length(group); 
    submat = 1:nsubs; 
    data = [];

    for which_sub = 1:nsubs
        subid = group{which_sub};
        for which_block = blocks
            filename = strcat(subid, '_aMotionRF_', num2str(which_block), '.mat');
            load(filename);
            if which_block == 1
                data = [data; emat(201:end, :)];
            else
                data = [data; emat(1:end, :)];
            end
        end
    end

    % columns
    resp_id = 4;
    dir_id = 3;
    noise_id = 6:size(data,2);

    % raw external noise stimuli 
    X = data(:,noise_id);

    % indices
    LorR = logical(data(:,dir_id) - 1); % to make it 0 or 1
    direction = LorR == 1; % select R
    response = data(:,resp_id) == 1;

    % flip R to L
    Xflip = flipDir(X, direction, nt, ns);
    Xflip = Xflip - 0.5; % subtract background level
    
    % variables
    n_trials = size(Xflip, 1);
    sigma_n = std(X(:));
    pcorrect = mean(response);

    % get q each trial
    for which_trial = 1:n_trials
        q(which_trial,:) = (n_trials/((n_trials-1)*sigma_n^2)) * (response(which_trial) - pcorrect) * Xflip(which_trial,:);
    end

    if which_group == 1
        q1 = q; 
    elseif which_group == 2
        q2 = q;
    end

end

%% calculate T & F

y = q1' - q2'; 
y_bar = mean(y,2);
n_cells = size(y,1);
S = cov(y');
T = n_trials * y_bar' * inv(S) * y_bar;
F = (n_trials - n_cells)/(n_cells*(n_trials-1)) * T;
pval = 1-fcdf(F, n_cells, n_trials-n_cells); 
fprintf('T2 = %s, F(%s,%s) = %s,  p = %s  \n', ... 
                num2str(T), ...
                num2str(n_cells), num2str(n_trials-n_cells), num2str(F), ...
                num2str(pval));

%% plot

filter_EB = reshape(mean(q1), nt, ns);
filter_SC = reshape(mean(q2), nt, ns);
filter_diff = reshape(y_bar, nt, ns); 

subplot(1,3,1); 
showSTA(filter_EB, {'EB', 'space', 'time'});

subplot(1,3,2); 
showSTA(filter_SC, {'SC', 'space', 'time'});

subplot(1,3,3); 
showSTA(filter_diff, {'Diff', 'space', 'time'});
