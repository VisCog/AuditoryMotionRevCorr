clear all;
close all;

ns = 10; nt = 10;

% load estimated parameters & sub IDs
EstParams; 
subjects; 

nsubs = size(params,1);
nEB = sum(group==1);

flag_save = 0;

obs_P = [];
pred_P = [];
sub_idx = [];
group_idx = [];
for which_sub = 1:nsubs

    % load observed filter
    if which_sub > nEB
        subid = SC{which_sub-nEB};
    else
        subid = EB{which_sub}; 
    end
    load(['P_', subid, '.mat']);

    % parameters
    poi.s = params(which_sub,:);
    poi.s = linspace(-30,30,ns); % space (deg)
    poi.t = linspace(0,0.8,nt); % time (s)
    poi.scenter = params(which_sub,2);
    poi.swidth = params(which_sub,3);
    poi.tcenter = params(which_sub,4);
    poi.twidth = params(which_sub,5);
    poi.a = params(which_sub,1);
    
    % make prediction
    prediction = func_STfilter2(poi); 
    
    % correlation 
    rho(which_sub,1) = corr(P(:), prediction(:));

    % R2
    R2(which_sub,1) = 1 - ( sum( (P(:)-prediction(:)).^2 ) / sum( (P(:)-mean(P(:))).^2 ) );

    % stack
    obs_P = [obs_P; P(:)];
    pred_P = [pred_P; prediction(:)];
    sub_idx = [sub_idx; ones(size(P(:))).*which_sub];
    group_idx = [group_idx; ones(size(P(:))).*group(which_sub)];


end

%% descriptive stats

EBstats_rho = [mean(rho(group==1)), std(rho(group==1))]
SCstats_rho = [mean(rho(group==2)), std(rho(group==2))]
EBstats_R2 = [mean(R2(group==1)), std(R2(group==1))]
SCstats_R2 = [mean(R2(group==2)), std(R2(group==2))]


%% plot all 

scale = [-0.05 0.05];

subplot(1,2,1); 
scatter(obs_P(group_idx==1), pred_P(group_idx==1), 'bo'); hold on;
axis square;
xlim(scale);
ylim(scale);
plot(xlim, ylim, 'k-');

subplot(1,2,2); 
scatter(obs_P(group_idx==2), pred_P(group_idx==2), 'ro'); hold on;
axis square;
xlim(scale);
ylim(scale);
plot(xlim, ylim, 'k-');

%% save

if flag_save 
    groups = {'EB', 'SC'};
    groupcell = groups(group_idx);
    datamat = [sub_idx, obs_P, pred_P];
    datacell = [groupcell', num2cell(datamat)];
    datatable = cell2table(datacell, 'VariableNames', {'group', 'sub', 'obs', 'pred'});
    savename = 'gof.csv';
    writetable(datatable, savename);
end
