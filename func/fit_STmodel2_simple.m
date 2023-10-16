function err = fit_STmodel2_simple(params,data)

Filter = func_STfilter2_simple(params);

residuals = data - Filter; 
err = sum(residuals(:).^2); 

end