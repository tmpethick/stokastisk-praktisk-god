function fracOfBlockedCus = ErlangB(arrivalIntensity,meanServiceTime,numServers)

   A = arrivalIntensity*meanServiceTime;
   
   % theoreitcal fraction of blocked customers
   fracOfBlockedCus = ...
       (A^numServers/(factorial(numServers)))/(sum(A.^(0:numServers)./...
        (factorial(0:numServers))));
   
end

