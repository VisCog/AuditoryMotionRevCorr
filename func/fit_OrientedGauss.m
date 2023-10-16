function err = fit_OrientedGauss(params, data)

Filter = func_OrientedGauss(params);
err = SSE(Filter, data);

end