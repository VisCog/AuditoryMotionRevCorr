clear all;
close all;

nx = 10;

% fit individual filters (separate gaussians for space and time - simple model)

subjects;

which_group = 2;

for which_sub = 1:8
    
    if which_group == 1
        group = EB;
    elseif which_group == 2
        group = SC;
    end
    
    subid = group{which_sub};
    
    load(['P_', subid, '.mat']);

    % initial params
    params.x = linspace(-1, 1, nx);
    params.center = 0.9999;
    params.width = 0.6;
    params.a = 0.03; 
    
    % fit
    freeList = {'1>a>0','1>center>0.3', '0.8>width>0'};
    [params,err] = fitcon('fit_STmodel2_simple', params, freeList, P);
    
    % prediction
    Filter = func_STfilter2_simple(params);
    
	% plot
    figure(1);
    subplot(8,2,1+(which_sub-1)*2);
    showSTA(P, {'data', 'space', 'time'}, 0.03);
    subplot(8,2,2+(which_sub-1)*2);
    showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    
    crosscorr = dot(P(:), Filter(:));
    
    estmat(which_sub,:) = [params.a params.center params.width err crosscorr];

end