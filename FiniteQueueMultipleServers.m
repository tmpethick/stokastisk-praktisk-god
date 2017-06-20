function Wq = FiniteQueueMultipleServers(arrivalIntensity,...
                                meanServiceTime,numServers,populationSize)
                            
   lambda   = arrivalIntensity;
   mu       = meanServiceTime;
   N        = populationSize;
   s        = numServers;
   n1       = 0:s-1;
   n2       = s:N;
   n3       = 1:s-1;
   p        = zeros(N+1,1);
   
   p(1) = 1/(sum(factorial(N)./(factorial(N-n1).*factorial(n1)).*(lambda/mu).^n1) +...
       sum(factorial(N)./(factorial(N-n2).*factorial(s).*s.^(n2-s)).*(lambda/mu).^n2));
   
   p(n3) = factorial(N)./(factorial(N-n3).*factorial(n3)).*(lambda/mu).^n3 .*p(1);
   p(n2) = factorial(N)./(factorial(N-n2).*factorial(s).*s.^(n2-s)).*(lambda/mu).^n2 .* p(1);
   
   Lq = sum((n2-s).*p(s:N)');
   
   Wq = Lq/lambda;
   

end