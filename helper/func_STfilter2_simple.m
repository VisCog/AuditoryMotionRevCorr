function Filter = func_STfilter2_simple(params)

[xx, yy] = meshgrid(params.x, params.x); 

ps.s = xx;
ps.center = params.center;
ps.width = params.width;

pt.s = yy;
pt.center = -params.center;
pt.width = params.width; 

Space1 = func_Gaussian(ps);
Space2 = fliplr(Space1);

Time1 = func_Gaussian(pt);
Time2 = flipud(Time1);

Filter = params.a .* (Space1.*Time1 + Space2.*Time2 - Space1.*Time2 - Space2.*Time1); 


end