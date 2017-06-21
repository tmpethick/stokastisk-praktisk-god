function [Wq] = FiniteQueueMultipleServers(arrivalIntensity,...
                                meanServiceTime,numServers,populationSize)
                            
   lambda   = arrivalIntensity;
   mu       = meanServiceTime;
   N        = populationSize;
   s        = numServers;
   n1       = 0:s-1;
   n2       = s:N;
   n3       = 1:s-1;
   p        = zeros(N,1);
   
   p0 = 1/(sum(factorial(N)./(factorial(N-n1).*factorial(n1)).*(lambda/mu).^n1) +...
       sum(factorial(N)./(factorial(N-n2).*factorial(s).*s.^(n2-s)).*(lambda/mu).^n2));
   
   p(n3) = factorial(N)./(factorial(N-n3).*factorial(n3)).*(lambda/mu).^n3 .*p0;
   p(n2) = factorial(N)./(factorial(N-n2).*factorial(s).*s.^(n2-s)).*(lambda/mu).^n2 .* p0;
   
   Lq = sum((n2-s).*p(s:N)');
   
   L = sum(n3.*p(n3)') + Lq + s.*(1-(sum(p(n3)')+p0));
   
   lambdabar = lambda*(N-L);
   
   Wq = Lq/lambdabar;
   

end