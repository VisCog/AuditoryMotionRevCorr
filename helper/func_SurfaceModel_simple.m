function Filter = func_SurfaceModel_simple(p)

% params
% a: weight of 'img2'
% sf: spatial frequency of sines and cosines
% amp: amplitude
% xx & yy: sample space

[x, y] = meshgrid(p.xx, p.yy); 

% define img1 and img2
img1 = -sin(2*pi*p.sf*x).*sin(2*pi*p.sf*y);
img2 = cos(2*pi*p.sf*x).*cos(2*pi*p.sf*y);

Filter = p.amp * (img1 + p.a*img2);

end
