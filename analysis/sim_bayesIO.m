% bayesian ideal observer analysis for pnas revision, Spetember 2023

clear all;
close all;

%%% options -------------------------------------------------

% n interations 
niter = 1000; 

% normalize filter?
normfilter = 1; 

% internal noise settings (k)
noiseLevels = exp(linspace(log(0.1), log(5), 10)); 

% non-sep model settings
widthLevels = linspace(0.2, 0.9, 7); 

% sep model settings
sepcenterLevels = 0.5; 

% save results?
saveflag = 0; 

%%% ---------------------------------------------------------

% general settings
nt = 10;
ns = 10; 
n_offset = 2; 
offset_t = [1:n_offset nt-n_offset+1:nt];
offset_s = [1:n_offset ns-n_offset+1:ns];

% n models
nsepmodels = length(sepcenterLevels);
nmodels = length(widthLevels) + nsepmodels + 1;

% signal
sig = fliplr(eye(nt, ns)); 
sig(offset_t, offset_s) = 0; 

rowcount = 1;

for which_model = 1:nmodels

    % make model 
    if which_model < nmodels - nsepmodels % nonsep
        params.nx = nt; 
        params.xx = linspace(-1, 1, params.nx); 
        params.yy = params.xx; 
        params.center = 0; 
        params.ang = pi/4; 
        params.width = widthLevels(which_model); 
        params.amp = 1; 
        F_L = func_OrientedGauss(params);
        separability = 'non';
    elseif which_model == nmodels % signal
        F_L = sig; 
        separability = 'sig';
    else % sep
        params.nx = nt; 
        params.x = linspace(-1, 1, params.nx); 
        params.y = params.x; 
        params.center = sepcenterLevels(which_model-(nmodels-nsepmodels)+1); 
        params.width = 0.5;
        params.a = 1; 
        F_L = func_STfilter2_simple(params);
        separability = 'sep';
    end
    if normfilter % normalize?
        F_L = normalize_filter(F_L); 
    end
    
    % simulate at varying levels of internal noise
    for which_k = 1:length(noiseLevels)

        for which_iter = 1:niter

            fprintf('Currently running: noise %s/%s, model %s/%s, iteration %s/%s \n', ... 
                num2str(which_k), num2str(length(noiseLevels)), ...
                num2str(which_model), num2str(nmodels), ...
                num2str(which_iter), num2str(niter));
            
            [temp_threshold(which_iter), temp_P] = simRFstudy_bayesIO(sig, F_L, noiseLevels(which_k)); 
 
        end % for which_iter
        
        % record
        Threshold(which_k, which_model) = mean(temp_threshold); % record threshold for plotting
        Filter{which_k}(which_model,:) = mean(temp_P);
        saved_model(which_model).model = F_L; 
        datacell(rowcount, :) = {noiseLevels(which_k), which_model, params.width, separability, ...
            mean(temp_threshold)};
        rowcount = rowcount + 1;

    end % for which_k


end % for which_model

%% save results

if saveflag
    % get timestamp
    vec = datevec(now);
    yyyymmdd = sprintf('%04d%02d%02d', vec(1), vec(2), vec(3));
    hhmm = sprintf('%02d%02d', vec(4), vec(5));
    % save
    savename = ['simbayesIO_' num2str(yyyymmdd), '_', num2str(hhmm), '.mat'];
    save(savename, 'Threshold', 'noiseLevels', 'widthLevels');
    % csv
    datatable = cell2table(datacell, 'VariableNames', {'NoiseLevels', 'Model', 'Width', 'Separability', 'PredThresh'});
    savename_csv = 'bayesIdealObserver.csv';
    writetable(datatable, savename_csv);
end


%% plot

figure(1); clf
subplot('Position', [ .1 .3 .5, .6]);
clist = repmat(linspace(0, 0.8, nmodels-nsepmodels-1)', 1, 3);
clist = [clist; 0 0.8 0.4; 0 0.2 0.7]; 
ph = semilogx(repmat(noiseLevels', 1, nmodels), mag2db(Threshold) - mag2db(0.5), '-'); 
set(gca, 'ColorOrder', clist)
xlabel('Noise Levels');
ylabel('Predicted Threshold');
xlim([0.05 10]); 

legendcell = cell(1,nmodels);
for i = 1:nmodels
    legendcell{i} = ['model ' num2str(i)];
end
legend(legendcell, 'Location', 'NorthWest' );

pos = [.75 .9 .1 .1];
for model_id = 1:nmodels
    pos(2) = pos(2)-.1;
    s(model_id) = subplot('Position', pos);
    showSTA(saved_model(model_id).model, {['model', num2str(model_id)], 's', 't'}); 
    axis off
end

