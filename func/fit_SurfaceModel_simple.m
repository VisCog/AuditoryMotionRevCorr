function err = fit_SurfaceModel_simple(params, data)

Filter = func_SurfaceModel_simple(params);

residuals = data - Filter;
err = sum(residuals(:).^2); 

end