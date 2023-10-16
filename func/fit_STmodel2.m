function err = fit_STmodel2(params, data)

Filter = func_STfilter2(params);

residuals = data - Filter; 
err = sum(residuals(:).^2); 

end