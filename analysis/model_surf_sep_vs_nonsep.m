clear all;
close all;

% compare separable vs non-separable models (based on Surface Model)

nt = 10;
ns = 10;

subjects;

which_model = 2; % 1: separable / 2: non-separable
which_group = 2;

for which_sub = 1:8
    
    if which_group == 1
        group = EB;
    elseif which_group == 2
        group = SC;
    end
    
    subid = group{which_sub};
    
    load(['P_', subid, '.mat']);

    % define space
    params.xx = linspace(-1, 1, ns);
    params.yy = linspace(-1, 1, nt);
    
    % initial params
    params.sf = 0.5;
    params.amp = 1;
    if which_model == 1 % separable
        params.a = 0;
    elseif which_model == 2 % non-separable
        params.a = 1;
    end
    
    % fit
    freeList = {'1>sf>0', '0.1>amp>0'};
    [params,err] = fitcon('fit_SurfaceModel_simple', params, freeList, P);
    
    % prediction
    Filter = func_SurfaceModel_simple(params);
    
	% plot
    figure(1);
    subplot(8,2,1+(which_sub-1)*2);
    showSTA(P, {'data', 'space', 'time'}, 0.03);
    subplot(8,2,2+(which_sub-1)*2);
    showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    
    crosscorr = dot(P(:), Filter(:));
    
    estmat(which_sub,:) = [params.sf params.amp params.a err crosscorr];

end