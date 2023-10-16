% Plot estimated STfilter (STfilter2), correlation between thresholds and
% estimated parameters 

clear all;
close all;

subjects;
EstParams;

[nsub nparams] = size(params);

ns = 100;
nt = 100;

s = linspace(-30, 30, ns);
t = linspace(0, 0.8, nt);

[xx,yy] = meshgrid(s,t);

onset = [15 0.2];

thresholds = mag2db(thresholds) - mag2db(0.5);

flag_plotFilters = 0;

%%
for i = 1:nsub
    
    params_sub = params(i,:); 
    which_group = group(i); 
    
    est_params.s = linspace(-30,30,ns); % space (deg)
    est_params.t = linspace(0,0.8,nt); % time (s)
    est_params.a = params_sub(1);
    est_params.scenter = params_sub(2);
    est_params.swidth = params_sub(3);
    est_params.tcenter = params_sub(4);
    est_params.twidth = params_sub(5);
    
    % prediction
    Filter = func_STfilter2(est_params);
    
    % data
    if which_group == 1
        group_name = EB;
        which_sub = i;
    elseif which_group == 2
        group_name = SC;
        which_sub = i-nsub/2;
    end
    subid = group_name{which_sub};
    load(['P_', subid, '.mat']);
    
    
	% plot
    if flag_plotFilters
        figure(which_group);
        subplot(8,2,1+(which_sub-1)*2);
        showSTA(P, {'data', 'space', 'time'}, 0.03);
        subplot(8,2,2+(which_sub-1)*2);
        showSTA(Filter, {'pred', 'space', 'time'}, 0.03);
    end
    
    % get peak coordinates
    temp = Filter(1:nt/2,ns/2+1:end);
    [maxval, maxid] = max(temp(:));
    tempcoord_x = xx(1:nt/2, ns/2+1:end);
    tempcoord_y = yy(1:nt/2, ns/2+1:end);
    
    peak_coord(i,:) = [tempcoord_x(maxid) tempcoord_y(maxid)];
    
end

%% 

figure(3); 
subplot(1,5,1); 
scatter(peak_coord(group==1,1), peak_coord(group==1,2)); hold on;
scatter(peak_coord(group==2,1), peak_coord(group==2,2)); 
scatter(onset(1), onset(2), 'kd', 'filled');
axis square;
set(gca, 'YDir', 'reverse');
set(gca, 'box', 'on');
ylim([0 0.8]);
xlim([-30 30]);
xticks([-30 -15 0 15 30]);
% xticklabels({'-30', '30'});
% yticklabels({'0', '0.8'});
xlabel('space'); ylabel('time'); legend('EB peak', 'SC peak', 'stim onset', 'Location', 'SouthWest');

subplot(1,5,2); 
scatter(peak_coord(group==1,1), thresholds(group==1)); hold on;
scatter(peak_coord(group==2,1), thresholds(group==2)); 
xlabel('space peak'); ylabel('threshold');
axis square;
refline;
ylim([0 12]);

subplot(1,5,3);
scatter(peak_coord(group==1,2), thresholds(group==1)); hold on;
scatter(peak_coord(group==2,2), thresholds(group==2)); 
xlabel('time peak'); ylabel('threshold');
axis square;
refline;
ylim([0 12]);

subplot(1,5,4); 
peak_coord2(:,1) = peak_coord(:,1)./60; 
peak_coord2(:,2) = peak_coord(:,2)./0.8; 
onset2(1) = onset(1)/60;
onset2(2) = onset(2)/0.8;
Distance = sqrt((peak_coord2(:,1) - onset2(1)).^2 + (peak_coord2(:,2) - onset2(2)).^2);
scatter(Distance(group==1), thresholds(group==1)); hold on;
scatter(Distance(group==2), thresholds(group==2)); hold on;
xlabel('NormDist to StimOnset'); ylabel('threshold');
xlim([0 0.6]);
ylim([0 12]);
axis square;
refline;

[rho_dist(1), p_dist(1)] = corr(Distance(group==1), thresholds(group==1));
[rho_dist(2), p_dist(2)] = corr(Distance(group==2), thresholds(group==2))

subplot(1,5,5);
params_amp = params(:,1);
scatter(params_amp(group==1), thresholds(group==1)), hold on;
scatter(params_amp(group==2), thresholds(group==2)), hold on;
xlabel('amp'); ylabel('threshold');
xlim([0 0.1]);
ylim([0 12]);
axis square;
refline; 

[rho_amp(1), p_amp(1)] = corr(params_amp(group==1), thresholds(group==1));
[rho_amp(2), p_amp(2)] = corr(params_amp(group==2), thresholds(group==2))


[rho_space(1), p_space(1)] = corr(peak_coord(group==1, 1), thresholds(group==1));
[rho_space(2), p_space(2)] = corr(peak_coord(group==2, 1), thresholds(group==2))

[rho_time(1), p_time(1)] = corr(peak_coord(group==1, 2), thresholds(group==1));
[rho_time(2), p_time(2)] = corr(peak_coord(group==2, 2), thresholds(group==2))



