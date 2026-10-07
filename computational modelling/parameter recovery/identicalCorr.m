function score = identicalCorr(x, y)
    % identicalCorr: replicate R function
    x = x(:);
    y = y(:);
    
    tmpErr = NaN(length(x), 1);
    for i = 1:length(x)
        tmpErr(i,1) = (y(i) - x(i))^2;
    end
    
    MSE = (1/length(y)) * sum(tmpErr(:,1));
    var_y = var(y, 0);  % sample variance, matches R
    
    score = 1 - (MSE / var_y);
end
