function probWaitForService = ErlangC(arrivalIntensity,meanServiceTime,numServers)

   A = arrivalIntensity*meanServiceTime;
   
   % theoreitcal probability that a customer has to wait for service
   probWaitForService = ...
       (A^numServers/(factorial(numServers))*numServers/(numServers-A))/...
       (sum(A.^(0:(numServers-1))./factorial(0:(numServers-1)))+ ...
       A^numServers/factorial(numServers)* numServers/(numServers-A));
   
end