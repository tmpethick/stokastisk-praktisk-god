function probBlockedCus = FiniteQueueOneServer(arrivalIntensity,...
                                meanServiceTime,maxQueueLength)
    Q = maxQueueLength;
    A = arrivalIntensity*meanServiceTime;
    
    probBlockedCus = A^(Q+1)*(1-A)/(1-A^(Q+2));


end