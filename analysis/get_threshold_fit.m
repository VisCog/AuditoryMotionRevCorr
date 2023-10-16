% estimate thresholds by fitting weibull 
% dependencies: psignifit toolbox

clear all;
close all;
clc;

subjects;

which_group = 1;
which_sub = 1;

if which_group == 1
    group = EB;
elseif which_group == 2
    group = SC;
end

nsub = length(group);

id_amp = 5;
id_q = 2;
id_resp = 4;

subid = group{which_sub};

blocks = 6;
nblocks = length(blocks);

m = 1;
blockcount = 1;

for which_block = blocks
    
    % load data
    
    fname = [subid, '_aMotionRF_', num2str(which_block), '.mat'];
    load(fname);
    
    for which_q = 1:2
        
        % discard first 200 trials of the first block as practice
        if which_block == 1
            emat = emat(201:end,:);
        end
        
        doi = emat(emat(:,id_q) == which_q, [id_amp, id_resp]);
        
        % data structure for psignifit toolbox (stimlevel, pcorrect, totaln)
        
        amplitudes = unique(doi(:,1));
        data = nan(length(amplitudes),3);
        
        for which_amp = 1:length(amplitudes)
            
            temp_amp = amplitudes(which_amp);
            temp_doi = doi(doi(:,1)==temp_amp,:);
            ndatapoints = size(temp_doi,1);
            temp_pcorrect = sum(temp_doi(:,2))/ndatapoints;
            data(which_amp,:) = [temp_amp, temp_pcorrect, ndatapoints];
            
        end % which_amp
        
        % setup psignifit
        options = struct;
        options.sigmoidName = 'weibull';
        options.expType = '2AFC';
        options.threshPC = 0.65;
        
        options.fixedPars = NaN(5,1);
        options.fixedPars(3) = .01;
        
        
        % run psignifit
        result = psignifit(data, options);
        
        result.Fit;
        result.conf_Intervals;

        pthresh = 0.65;
        [threshold(m),CI] = getThreshold(result,pthresh);
        slope = getSlopePC(result,pthresh);
        
        % plot
        figure(which_sub);
        subplot(nblocks,2,which_q+2*(blockcount-1));
        plotPsych(result);
        
        m = m + 1;
        
    end % which_q
    
    blockcount = blockcount + 1;
    
end % which_block