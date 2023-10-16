function sta = getSTA(data, idx, nt, ns, gaussFilt)

% raw data
doi = data(idx, :);

% center data
doi = doi - mean(doi(:));

% mean
sta = mean(doi);
sta = reshape(sta,[nt, ns]);

if gaussFilt.yes
    sta = imgaussfilt(sta, gaussFilt.sigma);
end


end