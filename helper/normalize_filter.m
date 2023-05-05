function filter = normalize_filter(filter)

ind = find(filter>0);
filter(ind) = filter(ind)/sum(filter(ind));
ind = find(filter<0);
filter(ind) = filter(ind)/abs(sum(filter(ind)));

end