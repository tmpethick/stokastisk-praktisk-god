function intervals = confInt(X,alpha)

mu = mean(X);
sigma = sqrt(var(X));

m = length(X);
t = tinv(1-alpha/2,m-1);
intervals = [mu-sigma/sqrt(m)*t, mu+sigma/sqrt(m)*t];
end

