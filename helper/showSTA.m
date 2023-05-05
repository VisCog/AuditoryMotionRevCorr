function im = showSTA(sta, plotProp, sc, cmap)

largest = max(sta(:));
smallest = min(sta(:));

if exist('sc') && ~isempty(sc)
    lim = sc;
elseif (exist('sc') && isempty(sc)) || ~exist('sc')
    lim = max(abs(largest), abs(smallest));
end

% plot
im = imagesc(sta); 
if exist('plotProp', 'var') && ~isempty(plotProp)
    title(plotProp{1});
    xlabel(plotProp{2});
    ylabel(plotProp{3});
end
caxis([-lim lim]);

if ~exist('cmap')
    colormap(redblue);
else
    colormap(cmap);
end

axis square; 
colorbar;
set(gca,'XTick',[]); set(gca,'YTick',[]);

end
