function [stats,errors] = get_plotstats(data)

avg = nanmean(data);
sd = nanstd(data);

[n,~] = size(data);

sem = sd/sqrt(n);

up = avg + sem;
low = avg - sem; 

stats.avg = avg;
stats.sd = sd;
stats.sem = sem;

errors.low = low;
errors.up = up;

end