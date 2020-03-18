function d = modmahal(X,Y)
% X,Y = m by n matrices where m = samples and n = features
    X_m = mean(X);
    Y_m = mean(Y);
    cov_XY = (cov(X) + cov(Y))./2;
    d = 0.5*sqrt((X_m - Y_m)*(cov_XY\(X_m - Y_m)'));
end 

