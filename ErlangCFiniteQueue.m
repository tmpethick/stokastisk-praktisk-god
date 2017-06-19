function [p0, pB, pC] = ErlangCFiniteQueue(arrivalIntensity,...
                                meanServiceTime,numServers,maxQueueLength)

   A = arrivalIntensity*meanServiceTime;
   N = numServers;
   M = numServers + maxQueueLength;
   
   % probability that 0 customers will have to queue
   p0 = (sum(A.^(0:N-1)./(factorial(0:N-1))) +...
       A^N*(1-(A/N)^(M-N+1))/...
       (factorial(N)*(1-A/N)))^(-1);
   
   % probability for being blocked
   pB = A^M/(N^(M-N)*factorial(N))*p0;
   
   % probability a customer will need to queue
   pC = A^N/factorial(N)*p0;
   
end