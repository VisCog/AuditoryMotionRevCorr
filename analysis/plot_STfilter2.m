clear all;
close all;

nt = 10;
ns = 10;

% fit individual filters (separate gaussians for space and time)

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
    params.s = linspace(-30,30,ns); % space (deg)
    params.scenter = 29.99;
    params.swidth = 20;
    params.t = linspace(0,0.8,nt); % time (s)
    params.tcenter = 0.001; 
    params.twidth = 0.25;
    params.a = 0.04; 
    
    % fit
    freeList = {'0.1>a>0','30>scenter>20', '50>swidth>0','0.4>tcenter>0', '0.4>twidth>0'};
    [params,err] = fitcon('fit_STmodel2', params, freeList, P);
    
    % prediction
    Filter = func_STfilter2(params);
    
	% plot
    figure(1);
    subplot(8,2,1+(which_sub-1)*2);
    showSTA(P, {'data', 'space', 'time'}, 0.03);
    subplot(8,2,2+(which_sub-1)*2);
    showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    
    estmat(which_sub,:) = [params.a params.scenter params.swidth params.tcenter params.twidth err];

end