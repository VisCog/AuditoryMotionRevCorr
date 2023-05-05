function model = MakeModel(p)


if strcmp(p.modelType, 'box')
    
    model = ones(p.ns, p.nt) * -1;
    pos = ones(p.boxsize, p.boxsize); 
    model(1:p.boxsize, end-p.boxsize+1:end) = pos; 
    model(end-p.boxsize+1:end, 1:p.boxsize) = pos;
%     pos = ones(p.nt/2, p.ns/2);
%     neg = ones(p.nt/2, p.ns/2) * -1; 
%     model = [neg, pos; pos, neg];
    
elseif strcmp(p.modelType, 'diagonal')
    
    if mod(p.diagwidth,2) == 0 
        error('Error: diagwidth should be an odd number')
    end
    
    if p.diagwidth > p.nt
        error('Error: diagwidth should be smaller than nt or ns');
    end
    
    i_order = 1:p.diagwidth;
    i_order = i_order - ceil(p.diagwidth/2);
    
    model = zeros(p.nt, p.ns);
    
    for i = 1:length(i_order)
        
        v = ones(1, p.nt-abs(i_order(i)));
        model = model + diag(v,i_order(i));
        
    end
    
    model = fliplr(model);
    model(model == 0) = -1;
    
elseif strcmp(p.modelType, 'flat')
    
    model = ones(p.nt, p.ns);
    
elseif strcmp(p.modelType, 'widespace')
    
    model = ones(p.nt, p.ns) * -1;
    model(1:p.timewidth,1:p.ns/2) = 1; 
    model(p.nt-(p.timewidth-1):p.nt,p.ns/2+1:p.ns) = 1;
    model = fliplr(model);
    
elseif strcmp(p.modelType, 'narrowspace')
    
    model = ones(p.nt, p.ns) * -1;
    model(1:p.nt/2, 1:p.spacewidth) = 1;
    model(p.nt/2+1:p.nt, p.ns-(p.spacewidth-1):p.ns) = 1;
    model = fliplr(model);
    
elseif strcmp(p.modelType, 'sep')
    
    p.s = linspace(-5, 5, p.ns);
    p.t = linspace(-5, 5, p.nt);
    p.a = 1;
    model = func_STfilter2(p);
    model = fliplr(model);
    
elseif strcmp(p.modelType, 'nonsep')
    
    p.s = linspace(-5, 5, p.ns);
    p.t = linspace(-5, 5, p.nt);
    p.x0 = 0;
    p.y0 = 0;
    p.amp = 1;
    p.theta = pi/4;
    model = func_2DGauss(p);
    model(model == 0) = -1;
    
end
if isfield(p, 'normalize') && p.normalize
ind = find(model>0);
model(ind) = 1/length(ind);
ind = find(model<0);
model(ind) = -1/length(ind);
end



end