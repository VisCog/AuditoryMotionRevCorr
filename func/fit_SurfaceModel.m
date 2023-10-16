function err = fit_SurfaceModel(params, data)

Filter = func_SurfaceModel(params);

residuals = data - Filter;
err = sum(residuals(:).^2); 

end