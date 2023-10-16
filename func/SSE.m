function err = SSE(pred, data)

residuals = data - pred;
err = sum(residuals(:).^2); 

end