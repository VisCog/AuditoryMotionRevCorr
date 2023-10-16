function Filter = func_OrientedGauss(params)


[X, Y] = meshgrid(params.xx, params.yy); 

% rotate the coordinate frame by params.ang
xrot = cos(params.ang)*X + sin(params.ang)*Y;
yrot = -sin(params.ang)*X + cos(params.ang)*Y;

% gaussian
Filter = exp(-(xrot-params.center).^2/params.width^2); 

% scale so we have negative space (-amp to amp)
Filter = (params.amp*2) * Filter - params.amp;


end