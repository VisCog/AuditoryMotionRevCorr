clear all;
close all;

p.nt = 10;
p.ns = 10; 
p.s = linspace(-30, 30, p.ns);
p.t = linspace(0, 0.8, p.nt);

nsub = 8;
niter = 1;

noiseLevels = [1.5 1.5]; 

flag_plot = 1;
flag_save = 0; 

% load parameter estimates
EstParams;

% signal
n_offset = 2; 
offset_t = [1:n_offset p.nt-n_offset+1:p.nt];
offset_s = [1:n_offset p.ns-n_offset+1:p.ns];
sig = fliplr(eye(p.nt, p.ns)); 
sig(offset_t, offset_s) = 0; 

%% simulation

for which_group = 1:2

    p.noiseFac = noiseLevels(which_group);

    for which_sub = 1:nsub
        
        temp_threshold = nan(niter, 1);
        for which_iter = 1:niter
            
            subid = which_sub + (which_group-1)*nsub

            p.a = params(subid,1);
            p.scenter = params(subid,2);
            p.swidth = params(subid,3);
            p.tcenter = params(subid,4);
            p.twidth = params(subid,5);

            model = func_STfilter2(p);

            [temp_threshold(which_iter,1)] = simRFstudy_CCModel(p, model);
        end
        
        pred_threshold(subid, 1) = nanmean(temp_threshold);

    end

end
    

%% save

if flag_save

    % get timestamp
    vec = datevec(now);
    yyyymmdd = sprintf('%04d%02d%02d', vec(1), vec(2), vec(3));
    hhmm = sprintf('%02d%02d', vec(4), vec(5));
    % save
    savename = ['behpred_' num2str(yyyymmdd), '_', num2str(hhmm), '.mat'];
    save(savename, 'pred_threshold');

end

%% plot

subplot(1,2,1);
limvals = [0 15];

pred_threshold = mag2db(pred_threshold) - mag2db(0.5);
thresholds = mag2db(thresholds) - mag2db(0.5);

scatter(thresholds(group==1), pred_threshold(group==1), 'bo'); hold on;
scatter(thresholds(group==2), pred_threshold(group==2), 'ro');
lsline;
plot(limvals, limvals, 'k-');
xlabel('Measured Threshold');
ylabel('Pred Threshold');

subplot(1,2,2); 
plot(group(group==1), pred_threshold(group==1), 'bo'); hold on;
plot(group(group==2), pred_threshold(group==2), 'ro');
xlim([0 3])

[r1, p1] = corr(thresholds(group==1), pred_threshold(group==1))
[r2, p2] = corr(thresholds(group==2), pred_threshold(group==2))