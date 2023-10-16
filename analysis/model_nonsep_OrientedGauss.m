clear all;
close all;

ns = 10;
nt = 10;
    
% fit individual filters
subjects;
which_group = 1;

for which_sub = 1:8
    
    if which_group == 1
        group = EB;
    elseif which_group == 2
        group = SC;
    end
    
    subid = group{which_sub};
    
    load(['P_', subid, '.mat']);
    
    % initial params
    params.center = 0;
    params.width = 0.5; 
    params.ang  = pi/4; % orientation
    params.amp  = 0.03; % amplitude
    
    % define space
    params.xx = linspace(-1, 1, ns);
    params.yy = linspace(-1, 1, nt);
    
    % fit
    freeList = {'1.6>ang>0', '1>width>0.2', '0.1>amp>0'};
    [params,err] = fitcon('fit_OrientedGauss', params, freeList, P);
    
    % prediction
    Filter = func_OrientedGauss(params);
    
    crosscorr = dot(P(:), Filter(:));
    
    % plot
    figure(1);
    subplot(8,2,1+(which_sub-1)*2);
    showSTA(P, {'data', 'space', 'time'}, 0.03);
    subplot(8,2,2+(which_sub-1)*2);
    showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    
    estmat(which_sub,:) = [params.amp params.ang params.width err crosscorr];
    
end