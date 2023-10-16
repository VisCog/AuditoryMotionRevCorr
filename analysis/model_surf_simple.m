clear all;
close all;

nt = 10;
ns = 10;

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
    params.sf = 0.5;
    params.amp = 1;
    params.a = 0;
    
    % define space
    params.xx = linspace(-1, 1, ns);
    params.yy = linspace(-1, 1, nt);
    
    % fit
    freeList = {'1>sf>0', '0.1>amp>0', '2>=a>=-0.5'};
    [params,err] = fitcon('fit_SurfaceModel_simple', params, freeList, P);
    
    % prediction
    Filter = func_SurfaceModel_simple(params);
    
    % plot
    figure(1);
    subplot(8,2,1+(which_sub-1)*2);
    showSTA(P, {'data', 'space', 'time'}, 0.03);
    subplot(8,2,2+(which_sub-1)*2);
    showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    
    estmat(which_sub,:) = [params.sf params.amp params.a err];
    
end