function G = func_Gaussian(p)

% s: space, or time, samples
% center: center of gaussian
% width: tuning 

G = exp(-(p.s-p.center).^2/p.width^2);

end