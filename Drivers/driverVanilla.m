%% This driver experiments with the vanilla model - with a single customer type and without server breaks
% The following parameters should not be modified in this driver
N = struct();
N.isBreakPossible   = false;
N.probManyItems     = 0;


%% Set parameters
N.maxPreSpace       = 50000;
N.maxQueueLength    = 5;

% maxServers does not matter in this driver, since isBreakPossible = false.
% Just ensure that maxServers is larger than initialServers
N.initialServers    = 2;
N.maxServers        = 2;
%Set commonqueue to for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 0;
N.numExperiments    = 50;
N.maxT              = 60*14;
N.burnInPeriod      = 0;
N.breakThresholds   = [0.7 1];
N.printProgress     = false;

D               = struct();
D.fewItemsDist  = @() lognrnd(0.6,0.3);        % mean service time for self-service
D.manyItemsDist = @() exprnd(1);        % mean service time for normal service
D.arrivalDist   = @() PertDist(0.017,1.5,10,[],1);     % mean inter arrival time
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function
numExperimentGridPoints = 10;
serviceTimeMeans = linspace(0.2,1.5,numExperimentGridPoints);
interArrivalModes = linspace(1/12, 2, numExperimentGridPoints);

queueTimeStats = cell(numExperimentGridPoints);
DONStruct = cell(numExperimentGridPoints);
for i = 1:length(serviceTimeMeans)
    for j = 1:length(interArrivalModes)
        fprintf('i,j: %d, %d\n',i,j)
        D.fewItemsDist  = @() lognrnd(serviceTimeMeans(i),0.3);
        D.arrivalDist   = @() PertDist(0.017,interArrivalModes(j),10,[],1);
        O = main(D, N);
        DONStruct{i,j}.D = D;
        DONStruct{i,j}.O = O;
        DONStruct{i,j}.N = N;
        queueTimeStats{i,j}.meanVec = cellfun(@mean, O.queueTimes);
        queueTimeStats{i,j}.varVec = cellfun(@var, O.queueTimes);
        queueTimeStats{i,j}.medianVec = cellfun(@median, O.queueTimes);
    end
end
%%
clear i j D O N
c = clock;
save(sprintf('Drivers/driverVanillaExp-%d-%d-%d-%d-%d',c(1),c(2),c(3),c(4),c(5)))
%% meanMatrix
meanMatrix = zeros(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(queueTimeStats{i,j}.meanVec);
    end
end

imagesc((log(meanMatrix)))
title('Mean queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
%% stdMatrix
stdMatrix = zeros(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        stdMatrix(i,j) = mean(sqrt(queueTimeStats{i,j}.varVec));
    end
end
imagesc(log(stdMatrix))
title('Mean queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar;

%% Print and plot output

% Print blocking fractions for all experiments and mean blocking fraction
% stringToPrint = sprintf('%.3f ', (O.blockedCounts./O.customerCounts)');
% fprintf('Blocking fractions for different experiments:\n%s\n',stringToPrint)
% fprintf('Mean of all Blocking fractions: %.3f\n',mean(O.blockedCounts./O.customerCounts))
% 
% combinedQueueTimes = [];
% for i = 1:length(O.queueTimes)
%     combinedQueueTimes = [combinedQueueTimes; O.queueTimes{i}'];
% end
% 
% 
% figure
% subplot(1,2,1)
% histogram(combinedQueueTimes(combinedQueueTimes > 0))
% title('Histogram of queue times')
% xlabel('Queue time (minutes)')
% ylabel('Frequency')
% set(gca,'Fontsize',14)
% subplot(1,2,2)
% bar(O.serversOccupiedTimes(1,:)/N.maxT)
% title('Bar plot of "server efficiency"')
% ylim([0 1])
% xlabel('Server index')
% ylabel('Occupied time / total time')
% set(gca,'Fontsize',14)