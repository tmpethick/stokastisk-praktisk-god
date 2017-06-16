%% This driver experiments with the vanilla model - with a single customer type and without server breaks

%% Set parameters
N = struct();
N.maxPreSpace       = 50000;
N.maxQueueLength    = 5;
N.initialServers    = 2;
N.maxServers        = 2;
%Set commonqueue to for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 0;
N.probManyItems     = 0;
N.numExperiments    = 1;
N.maxT              = 60*12*14;
N.burnInPeriod      = 0;
N.breakThresholds   = [0.7 1];
N.isBreakPossible   = false;

D               = struct();
D.fewItemsDist  = @() lognrnd(3,0.3);        % mean service time for self-service
D.manyItemsDist = @() exprnd(1);        % mean service time for normal service
D.arrivalDist   = @() PertDist(0.05,2.5,7,[],1);     % mean inter arrival time
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(3);

%% Call main function
O = main(D, N);

%% Print and plot output
% Print blocking fractions for all experiments and mean blocking fraction
disp((O.blockedCounts./O.customerCounts)')
disp(' ')
disp(mean(O.blockedCounts./O.customerCounts))

figure
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