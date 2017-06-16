%% Set parameters
N = struct();
N.maxPreSpace = 10000;
N.maxQueueLength = 10;
N.initialServers = 5;
N.maxServers = 10;
N.isCommonQueue = 0;  %Set to for a single common queue. Set to 0 for many queues, i.e. one queue for each server
N.probManyItems = 0;
N.numExperiments = 10;
N.maxT = 60*14*12;
N.burnInPeriod = 60*14;
N.breakThresholds = [0.7 1];
N.isBreakPossible = true;

D = struct();
D.fewItemsDist = @() exprnd(8);            % mean service time for self
D.manyItemsDist = @() exprnd(1);          % mean service time for normal
D.arrivalDist = @() exprnd(1);            % mean inter arrival time
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