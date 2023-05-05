% Reverse correlation to measure auditory motion RF 
% Task: motion discrimination (L or R) 

clear all;
close all;
clc;

t1 = GetSecs;

%% Basic settings

rand('seed', sum(100 * clock));
ListenChar(2);

id              = 'test';
whichsess       = 1;

fname = strcat([id, '_aMotionRF_',num2str(whichsess),'.mat']);
IsExist = exist(fname,'file');
if IsExist ~= 0
    ListenChar(1);
    error('data file name exists')
end

%% Audio settings

nrchannels = 2;
Fs = 44100;

InitializePsychSound; % Perform basic initialization of the sound driver
pahandle = PsychPortAudio('Open', [], [], 0, Fs, nrchannels);

%% Stimulus settings

% nsamples_time_targ  = 10;
% nsamples_space_targ = 10;

% padsamples          = 3;

nsamples_time_noise = 10;
nsamples_space_noise = 10; 

depth               = 0.8; % meters
traveldeg           = 15; % *2 deg % 15

p.Fs                = Fs; 
p.doppler           = 0;
p.itd               = 1;
p.ild               = 1;
p.inverseSquareLaw  = 1; 

p.lowCutoff         = 500;
p.highCutoff        = 14000;
p.noiseType         = 'Notch'; 
p.RiseFallDur       = 0.05; 

p.orbital           = 0;

p.dur               = 0.5; 

paddur              = 0.15;

dt                  = 0.08; % p.dur/nsamples_time_targ; % sec
ds                  = 4.8; % traveldeg*2/nsamples_space_targ;

pnoise              = p;
pnoise.dur          = dt; % for each cell in the designmat
pnoise.RiseFallDur  = 0.01;

traveldeg_noise     = ds*3 + traveldeg;


%% Staircase

if whichsess == 1
    tGuess          = [1.5 1.5]; % 0.5 0.5
else
    load(strcat([id, '_aMotionRF_',num2str(whichsess-1),'.mat']));
    tGuess          = [QuestQuantile(stair1) QuestQuantile(stair2)];
    clear emat stair1 stair2;
end
sdGuess             = 0.1;
pThreshold          = 0.65;
beta                = 3.5;
delta               = 0.02;
gamma               = 0.5;

stair1 = QuestCreate(tGuess(1),sdGuess,pThreshold,beta,delta,gamma);
stair2 = QuestCreate(tGuess(2),sdGuess,pThreshold,beta,delta,gamma);

%% Exp design

nrepeat = 250; % nrepeat * 4 = total_trials 
nquest = 2;
ndir = 2; 
emat = expmat(1:nquest, 1:ndir);
emat = repmat(emat, nrepeat, 1);
[eseq, emat] = randseq(emat); 
[ex, ey] = size(emat); 
saveindex = ey + 1; 
total_trials = size(emat,1);
trialsperblock = 200; 

feedback = 1;
breakdur = 30; 

%% Keyboard settings

keyboardIndices = GetKeyboardIndices;
keyboardnum = -3;

ApplyKbFilter;

%% Experiment 

disp('press any key to begin');
KbWait(keyboardnum,3);
WaitSecs(0.5);

blockid = 1; 

for seq = eseq
    
    which_trial = emat(seq,1);
    which_quest = emat(seq,2); 
    which_dir   = emat(seq,3); 
    
    disp(['trial ', num2str(which_trial)]);
    
    % get atten_factor 
    if which_quest == 1
        atten_factor = QuestQuantile(stair1);
    elseif which_quest == 2
        atten_factor = QuestQuantile(stair2);
    end
    atten_factor = min(2, max(atten_factor, 0.001));
    
    % define target trajectory 
    if which_dir == 1
        p.startxy = [depth*tand(traveldeg) depth];
        p.endxy = [-depth*tand(traveldeg) depth];
    elseif which_dir == 2
        p.startxy = [-depth*tand(traveldeg) depth];
        p.endxy = [depth*tand(traveldeg) depth];
    end
    [xx, yy] = MakeTrajectory(p);
    
    % generate target sound 
    target = MakeAuditoryNoise(p);
    target = auditoryCueIntegrator(p, target, xx, yy);
    target = RiseFall(p, target) .* atten_factor; % two column vectors  
    
    % add zero padding for target (to match with noise dur)
    nrow = paddur*Fs;
    target = [zeros(nrow,size(target,2)); target; zeros(nrow,size(target,2))];
    
    % define noise matrix 
    designmat = randn(nsamples_time_noise, nsamples_space_noise); 
    designmat = designmat./max(max(abs(designmat)));
    designmat = (designmat + 1)./2;
    
    % sample space
    space = linspace(-depth*tand(traveldeg_noise), depth*tand(traveldeg_noise), nsamples_space_noise);
    
    % generate noise sound
    noise = [];
    
    for i = 1:nsamples_time_noise
        
        snoise = zeros(pnoise.dur*pnoise.Fs,2);
        
        for j = 1:nsamples_space_noise
            
            % define noise trajectory 
            pnoise.startxy = [space(j) depth];
            pnoise.endxy = [space(j) depth];
            [xxn, yyn] = MakeTrajectory(pnoise);
            
            temp_noise = MakeAuditoryNoise(pnoise);
            temp_noise = auditoryCueIntegrator(pnoise, temp_noise, xxn, yyn); 
            temp_noise = RiseFall(pnoise, temp_noise) .* designmat(i,j);
            
            snoise = snoise + temp_noise; 
            
        end
        
        noise = [noise; snoise];
        
    end
    
    % add noise + target
    playthis = (target + noise) * 0.9;
    
    % play
    PsychPortAudio('FillBuffer', pahandle, playthis');
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    WaitSecs(pnoise.dur*nsamples_time_noise);
    
    % response 
    [correct,endSecs] = get_response(which_dir, keyboardnum);
    if feedback == 1
        if correct == 1
            beep = MakeBeep(1000,0.02) * 0.5;
            Snd('Play',beep*0.8,p.Fs);
            disp(['correct - ' num2str(atten_factor)]);
        elseif correct == 0
            disp(['incorrect - ' num2str(atten_factor)]);
        end
    end
    WaitSecs(0.4);
    
    % record
    designmat2 = reshape(designmat, 1, nsamples_time_noise*nsamples_space_noise);
    emat(seq, saveindex) = correct;
    emat(seq, saveindex+1) = atten_factor;
    emat(seq, saveindex+2:saveindex+1+size(designmat2,2)) = designmat2; 
    
    % update Quest
    if which_quest == 1
        stair1 = QuestUpdate(stair1,atten_factor,correct); 
    elseif which_quest == 2
        stair2 = QuestUpdate(stair2,atten_factor,correct);
    end
    
    % break
    if rem(which_trial, trialsperblock) == 0 && which_trial ~= total_trials
        
        % break begin signal
        Snd('Play',sin((1:1000)/20));
        WaitSecs(.5)
        Snd('Play',sin((1:1000)/20));
        WaitSecs(.5)
        Snd('Play',sin((1:1000)/20));
        
        disp('break');
        
        % break countdown
        WaitSecs(breakdur);
        
        % break end signal
        Snd('Play',sin((1:1000)/4));
        WaitSecs(.5)
        Snd('Play',sin((1:1000)/4));
        WaitSecs(.5)
        Snd('Play',sin((1:1000)/4));
        
        blockid = blockid + 1;
        
        disp(['press any key to begin - block: ', num2str(blockid)]);
        KbWait(keyboardnum,3);
        WaitSecs(0.5);
        
    end
    
end

%% Save

emat = sortrows(emat);
dirname = strcat('@data');
if isdir(dirname) == 0
    mkdir(dirname);
end

cd(dirname);
save(fname, 'emat', 'stair1', 'stair2');
cd ..

%% Finish up

PsychPortAudio('Close', pahandle);
ListenChar(1);
t2 = GetSecs;
TotalTime = (t2 - t1)/60 
