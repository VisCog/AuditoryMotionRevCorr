% Simulate performance using 1D gauss (non-sep) and ST simple (sep) models 

clear all;
close all;

%% settings

saveflag = 0; 

niter = 1000; 

noiseLevels = exp(linspace(log(0.1), log(5), 10));
widthLevels = linspace(0.2, 0.8, 7); 
sepcenterLevels = 0.5; 

nsepmodels = length(sepcenterLevels);
nmodels = length(widthLevels) + nsepmodels;
modelLevels = 1:nmodels; % + 1 is the separable model 

normfilter = 1;

task = 'discriminate';

%% simulate

for which_noise = 1:length(noiseLevels)
    
    for model_id = 1:length(modelLevels)
        
        which_model = modelLevels(model_id);
        
        % make model 
        if model_id < nmodels - (nsepmodels-1)
            params.nx = 10; 
            params.xx = linspace(-1, 1, params.nx); 
            params.yy = params.xx; 
            params.center = 0; 
            params.ang = pi/4; 
            params.width = widthLevels(model_id); 
            params.amp = 1; 
            model = func_OrientedGauss(params);
        else
            params.nx = 10; 
            params.x = linspace(-1, 1, params.nx); 
            params.y = params.x; 
            params.center = sepcenterLevels(model_id-(nmodels-nsepmodels)); 
            params.width = 0.5;
            params.a = 1; 
            model = func_STfilter2_simple(params);
        end
        
        % normalize?
        if normfilter
            model = normalize_filter(model); 
        end
        
        % define p
        p.nt = 10;
        p.ns = 10;
        p.noiseFac = noiseLevels(which_noise);
        
        % simulate
        for which_iter = 1:niter
            
            fprintf('Currently running: noise %s/%s, model %s/%s, iteration %s/%s \n', ... 
                num2str(which_noise), num2str(length(noiseLevels)), ...
                num2str(which_model), num2str(length(modelLevels)), ...
                num2str(which_iter), num2str(niter));
            
            [temp_threshold(which_iter), P] = simRFstudy_CCModel(p, model, task); % this is where simulation happens

        end
        
        Threshold(which_noise, model_id) = mean(temp_threshold); % record threshold for plotting
        
        clear p;
        saved_model(model_id).model = model;  
        
    end
    
end

if saveflag
    % get timestamp
    vec = datevec(now);
    yyyymmdd = sprintf('%04d%02d%02d', vec(1), vec(2), vec(3));
    hhmm = sprintf('%02d%02d', vec(4), vec(5));
    % save
    savename = ['SimModels_' num2str(yyyymmdd), '_', num2str(hhmm), '.mat'];
    save(savename, 'Threshold', 'noiseLevels', 'widthLevels');
end

%% plot

figure(1); clf
subplot('Position', [ .1 .3 .5, .6]);
clist = repmat(linspace(0, 0.8, nmodels-nsepmodels)', 1, 3);
clist = [clist; 0 0.8 0.5; 0 0.8 0.3]; 
ph = semilogx(repmat(noiseLevels', 1, nmodels), mag2db(Threshold) - mag2db(0.5), '-'); 
set(gca, 'ColorOrder', clist)
xlabel('Noise Levels');
ylabel('Predicted Threshold');
xlim([0.05 10]); 

legendcell = cell(1,length(modelLevels));
for i = 1:length(modelLevels)
    legendcell{i} = ['model ' num2str(modelLevels(i))];
end
legend(legendcell, 'Location', 'NorthWest' );


pos = [.75 0.9 .1 .1];
for model_id = 1:length(modelLevels)
    pos(2) = pos(2)-.11;
    s(model_id) = subplot('Position', pos);
    image(127+(saved_model(model_id).model*127)); colormap(redblue(256)); drawnow
    axis off
end

