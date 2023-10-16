function Xflip = flipDir(X, idx, nt, ns)

Xflip = X; 
ntrials = size(X,1);

for i = 1:ntrials
    
    if idx(i)
        temp = fliplr(reshape(Xflip(i,:), [nt, ns]));
        Xflip(i,:) = reshape(temp, [1, nt*ns]);
    end
    
end

end