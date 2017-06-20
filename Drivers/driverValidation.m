%% Set parameters
N = struct();
N.maxPreSpace       = 100000;
N.maxQueueLength    = 10;
N.initialServers    = 1;
N.maxServers        = 1;
%Set commonQueue to 1 for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 1;
N.probManyItems     = 0;
N.numExperiments    = 1;
N.maxT              = 60*14*12;
N.burnInPeriod      = 60*14;
N.breakThresholds   = [0.7 1];
N.isBreakPossible   = false;
N.printProgress     = true;

arrivalIntensity            = 1;
meanServiceTimeFewItems     = 1.1;
meanServiceTimeManyItems    = 8;

D               = struct();
D.fewItemsDist  = @() exprnd(meanServiceTimeFewItems); 
D.manyItemsDist = @() exprnd(meanServiceTimeManyItems);        
D.arrivalDist   = @() exprnd(arrivalIntensity );        
%D.fewItemsDist  = @() 8;  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function

O = main(D, N);

%% Validation
% analytical solution for blocking fraction with no queue, 
% 1 customertype, no breaks, infinite population, 
% and poisson arrival process
ThProbOfBlockedCus = ErlangB(arrivalIntensity,meanServiceTimeFewItems,N.maxServers);

% theoretical probability that an arriving customer will need to queue,
% with inifinte queue, inifinite population, 1 customertype, no breaks,
% and poisson arrival process
ThProbCusMustQueue = ErlangC(arrivalIntensity,meanServiceTimeFewItems,N.maxServers);

% theoretical probability of being blocked with finite queue and 
% 1 server
thProbBlockedCus1Server = FiniteQueueOneServer(arrivalIntensity,...
                                meanServiceTimeFewItems,N.maxQueueLength);

% experimental probalibilty that customers are blocked
ExProbOfBlockedCus = mean(O.blockedCounts)/mean(O.customerCounts);

% experimental probability that customers must queue
ExProbCusMustQueue = zeros(N.numExperiments,1);
for i=1:N.numExperiments
    ExProbCusMustQueue(i) = nnz(cell2mat(O.queueTimes(i)))/O.customerCounts(i);
end
ExProbCusMustQueue = mean(ExProbCusMustQueue);

%%
% check if Little's law is satisfied
lambda = O.customersInSystem(1)/mean(cell2mat(O.responseTimes(1)));


%%
[p0, pB, pC] = ErlangCFiniteQueue(arrivalIntensity,meanServiceTimeFewItems,...
                                    N.maxServers,N.maxQueueLength);
