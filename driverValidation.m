%% Set parameters
N = struct();
N.maxPreSpace       = 100000;
N.maxQueueLength    = 100000;
N.initialServers    = 10;
N.maxServers        = 10;
%Set commonqueue to 1 for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 1;
N.probManyItems     = 0;
N.numExperiments    = 10;
N.maxT              = 60*14*12;
N.burnInPeriod      = 60*14;
N.breakThresholds   = [0.7 1];
N.isBreakPossible   = false;

arrivalIntensity            = 1;
meanServiceTimeFewItems     = 8;
meanServiceTimeManyItems    = 8;

D               = struct();
D.fewItemsDist  = @() exprnd(meanServiceTimeFewItems); 
D.manyItemsDist = @() exprnd(meanServiceTimeManyItems);        
D.arrivalDist   = @() exprnd(arrivalIntensity );        
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function
O = main(D, N);

%% Print and plot output
% Print blocking fractions for all experiments and mean blocking fraction
disp((O.blockedCounts./O.customerCounts)')
disp(' ')
disp(mean(O.blockedCounts./O.customerCounts))

subplot(1,2,1)
histogram(O.queueTimes{1}(O.queueTimes{1} ~= 0))
title('Histogram of queue times')
xlabel('Queue time (minutes)')
ylabel('Frequency')
set(gca,'Fontsize',14)
subplot(1,2,2)
bar(O.serversOccupiedTimes(1,:)/N.maxT)
title('Bar plot of "server efficiency"')
ylim([0 1])
xlabel('Server index')
ylabel('Occupied time / total time')
set(gca,'Fontsize',14)

%% Validation
% analytical solution for blocking fraction with no queue, 
% 1 customertype, no breaks, infinite population, 
% and poisson arrival process
ThProbOfBlockedCus = ErlangB(arrivalIntensity,meanServiceTimeFewItems,N.maxServers);

% theoretical probability that an arriving customer will need to queue,
% with inifinte queue, inifinite population, 1 customertype, no breaks,
% and poisson arrival process
ThProbCusMustQueue = ErlangC(arrivalIntensity,meanServiceTimeFewItems,N.maxServers);

% experimental probalibilty that customers are blocked
ExProbOfBlockedCus = mean(O.blockedCounts);

% experimental probability that customers must queue
ExProbCusMustQueue = zeros(N.numExperiments,1);
for i=1:N.numExperiments
    ExProbCusMustQueue(i) = nnz(cell2mat(O.queueTimes(i)))/O.customerCounts(i);
end
ExProbCusMustQueue = mean(ExProbCusMustQueue);
