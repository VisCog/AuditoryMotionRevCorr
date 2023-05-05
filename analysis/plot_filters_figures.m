% plot estimated filters for making figures

clear all; 
close all;

subjects;

nEB = length(EB);
nSC = length(SC);

ntotal = nEB + nSC; 

nt = 10;
ns = 10;

plot_individual = 1;
convert_to_z = 1;

if convert_to_z == 1
    scalelimit = 2;
else
    scalelimit = 0.04;
end

%% individual 

P_EB_all = [];
P_SC_all = [];

for i = 1:ntotal
    
    if i < nEB || i == nEB
        subid = EB{i};
    else
        subid = SC{i-nEB};
    end
    
    filename = ['P_' subid '.mat'];
    load(filename); 
    
    ThisFilter = P; 
    
    if convert_to_z
        P = reshape(zscore(ThisFilter(:)), nt, ns);
    end
    
    if i < nEB || i == nEB
        P_EB_all = [P_EB_all; reshape(P, 1, nt*ns)];
    else
        P_SC_all = [P_SC_all; reshape(P, 1, nt*ns)];
    end
    
    if plot_individual
        figure(1);
        subplot(2,nEB,i);
        showSTA(P, {'P', 'space', 'time'}, scalelimit); colorbar; 
    end
    
end

P_all = [P_EB_all; P_SC_all];

% difference (within pair)

Pdiff_all = [];

for i = 1:nEB
    
    subid_EB = EB{i};
    subid_SC = SC{i};
    
    filename_EB = ['P_' subid_EB '.mat'];
    filename_SC = ['P_' subid_SC '.mat'];
    
    load(filename_EB);
    P_EB = P;
    
    load(filename_SC);
    P_SC = P;
    
    if convert_to_z
        P_EB = reshape(zscore(P_EB(:)), nt, ns);
        P_SC = reshape(zscore(P_SC(:)), nt, ns);
    end
    
    Pdiff = P_EB - P_SC; 
    Pdiff_all = [Pdiff_all; reshape(Pdiff, 1, nt*ns)];
    
end


%% avg

% group avg 

P_EB_avg = mean(P_EB_all);
P_SC_avg = mean(P_SC_all);

P_EB_avg = reshape(P_EB_avg, [nt,ns]);
P_SC_avg = reshape(P_SC_avg, [nt,ns]);

figure(2);
subplot(1,4,1);
showSTA(P_EB_avg, {'EBavg', 'space', 'time'}, scalelimit);
set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);

subplot(1,4,2);
showSTA(P_SC_avg, {'SCavg', 'space', 'time'}, scalelimit);
set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);

% diff avg

Pdiff_avg = mean(Pdiff_all); 
Pdiff_avg = reshape(Pdiff_avg, [nt,ns]);

figure(2);
subplot(1,4,3);
showSTA(Pdiff_avg, {'Diffavg', 'space', 'time'}, scalelimit);
set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);

colorbar;


%% mcmc 

nsim = 10000; 

flag_smooth = 0;
sigma = 0.75;

LRsubtract = 1; % 1: fold the filter / 0: simulate as is
statType = 1; % 1: percentile / 2: 2SD
prctilemat = [2.5 97.5]; % [0 95] use only if LRsubtract=0  [2.5 97.5] [16 84]

if LRsubtract == 0
    sim_Pdiff = nan(nsim, nt*ns);
elseif LRsubtract == 1
    sim_Pdiff = nan(nsim, nt*ns/2);
end
 
for which_sim = 1:nsim
    
    % shuffle subjects 
    shuffled_order = randi(ntotal, 1, ntotal); % vs randperm
    temp_EB = shuffled_order(1:nEB);
    temp_SC = shuffled_order(nEB+1:end); 
    
    % get 'shuffled' pairs 
    temp_P_EB = P_all(temp_EB,:);
    temp_P_SC = P_all(temp_SC,:); 
    
    % get difference (the mean should be roughly around 0 = 'null' distribution)
    if LRsubtract == 0
        sim_Pdiff(which_sim,:) = mean(temp_P_EB - temp_P_SC);
    elseif LRsubtract == 1
        temp_P_all = [temp_P_EB; temp_P_SC];
        for i = 1:size(temp_P_all, 1)
            temp_P = temp_P_all(i,:);
            temp_P = reshape(temp_P, [nt, ns]);
            temp_P_L = temp_P(:, 1:ns/2);
            temp_P_R = temp_P(:, ns/2+1:end);
            temp_P_fold = temp_P_L - fliplr(temp_P_R); 
            temp_P_fold_all(i,:) = reshape(temp_P_fold, [1,nt*ns/2]);
        end
        temp_P_fold_EB = temp_P_fold_all(1:nEB, :);
        temp_P_fold_SC = temp_P_fold_all(nEB+1:end, :);
        sim_Pdiff(which_sim,:) = mean(temp_P_fold_EB - temp_P_fold_SC);
    end
    
    % smooth?
    if flag_smooth
        temp_sim_Pdiff = reshape(sim_Pdiff(which_sim,:), [nt, ns]); 
        temp_sim_Pdiff = imgaussfilt(temp_sim_Pdiff, sigma); 
        sim_Pdiff(which_sim,:) = reshape(temp_sim_Pdiff, [1,nt*ns]);
    end
    
end

% plot significance

if LRsubtract == 0
    actual_P = Pdiff_avg;
elseif LRsubtract == 1
    actual_P = Pdiff_avg(:,1:ns/2) - fliplr(Pdiff_avg(:,ns/2+1:end));
end

% percentile
sim_prctile_P = prctile(sim_Pdiff, prctilemat); 

smaller_P = reshape(actual_P, [1,size(actual_P,1)*size(actual_P,2)]) < sim_prctile_P(1,:);
bigger_P = reshape(actual_P, [1,size(actual_P,1)*size(actual_P,2)]) > sim_prctile_P(2,:);

sigidx_P = or(smaller_P, bigger_P);

if LRsubtract == 0
    sig_Pdiff = Pdiff_avg .* reshape(sigidx_P, [nt,ns]);
elseif LRsubtract == 1
    sigidx_P = reshape(sigidx_P, [nt,ns/2]); 
    sigidx_P = [sigidx_P fliplr(sigidx_P)];
    sig_Pdiff = Pdiff_avg .* sigidx_P;
end

% signifiance plots
figure(2);
subplot(1,4,4);
showSTA(sig_Pdiff, {'sigPdiff', 'space', 'time'}, scalelimit);
set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);

figure(3);
ax1 = axes;
im1 = imagesc(Pdiff_avg);
caxis([-scalelimit scalelimit]);
ax1.XTick = [];
ax1.YTick = [];
axis square;

ax2 = axes;
im2 = imagesc(Pdiff_avg);
im2.AlphaData = sigidx_P; 
caxis([-scalelimit scalelimit]);
ax1.XTick = [];
ax1.YTick = [];
axis square;

linkaxes([ax1,ax2]) 
ax2.Visible = 'off'; 
ax2.XTick = []; 
ax2.YTick = []; 
colormap(ax1,'gray') 
colormap(ax2,redblue) 

cb1 = colorbar(ax1,'Position',[.05 .11 .0675 .815]); 
cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]); 

