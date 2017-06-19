%% This driver experiments with the vanilla model - with a single customer type and without server breaks
% The following parameters should not be modified in this driver
N = struct();
N.isBreakPossible   = false;
N.probManyItems     = 0;


%% Set parameters
N.maxPreSpace       = 50000;

% maxServers does not matter in this driver, since isBreakPossible = false.
% Just ensure that maxServers is larger than initialServers
N.initialServers    = 2;
N.maxServers        = 2;
% Set commonqueue to for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 1;
N.maxQueueLength    = 5;
% Adjust max queue size such that common queue and no common queue
% scenarios are comparable
if N.isCommonQueue
    N.maxQueueLength = N.maxQueueLength*N.maxServers;
end
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
numExperimentGridPoints = 1;
serviceTimeMeans = linspace(0.65*0.7,0.65*1.3,numExperimentGridPoints);
interArrivalModes = linspace(0.3*0.7, 0.3*1.3, numExperimentGridPoints);

serviceTimeStats = cell(numExperimentGridPoints);
queueTimeStats = cell(numExperimentGridPoints);
waitTimeStats = cell(numExperimentGridPoints);
DONStruct = cell(numExperimentGridPoints);
for i = 1:length(serviceTimeMeans)
    for j = 1:length(interArrivalModes)
        fprintf('i,j: %d, %d\n',i,j)
        D.fewItemsDist  = @() lognrnd(serviceTimesMeans,0.3);
        D.arrivalDist   = @() PertDist(1/60,interArrivalModes(j),5,[],1);
        % Run experiment
        O = main(D, N);
        DONStruct{i,j}.D = D;
        DONStruct{i,j}.O = O;
        DONStruct{i,j}.N = N;
        
        % Compute stats
        serviceTimeStats{i,j} = cellfun(@mean, O.serviceTimes);
        serviceTimeStats{i,j} = cellfun(@var, O.serviceTimes);
        serviceTimeStats{i,j} = cellfun(@median, O.serviceTimes);
        queueTimeStats{i,j}.meanVec = cellfun(@mean, O.queueTimes);
        queueTimeStats{i,j}.varVec = cellfun(@var, O.queueTimes);
        queueTimeStats{i,j}.medianVec = cellfun(@median, O.queueTimes);
        waitTime = cellfun(@plus, O.queueTimes, O.serviceTimes,'Un',false);
        waitTimeStats{i,j}.meanVec = cellfun(@mean,waitTime);
        waitTimeStats{i,j}.varVec = cellfun(@var,waitTime);
        waitTimeStats{i,j}.medianVec = cellfun(@median,waitTime);

    end
end
%%
clear i j D O N
c = clock;
save(sprintf('Drivers/driverVanillaExp-%d-%d-%d-%d-%d-%d',c(1),c(2),c(3),c(4),c(5),c(6)))
%% Plot mean 
figure
meanMatrix = NaN(numExperimentGridPoints);
stdMatrix = NaN(numExperimentGridPoints);
medianMatrix = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(queueTimeStats{i,j}.meanVec);
        stdMatrix(i,j) = mean(sqrt(queueTimeStats{i,j}.varVec));
        medianMatrix(i,j) = mean(queueTimeStats{i,j}.medianVec);
        eventCountMatrix(i,j) = mean(DONStruct{i,j}.O.blockedCounts./(DONStruct{i,j}.O.customerCounts));
    end
end


subplot(2,2,1)
imagesc(meanMatrix)
title('Mean queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
caxis([0,18])
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));


subplot(2,2,2)
imagesc(medianMatrix)
title('Median for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
caxis([0,18])
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

subplot(2,2,3)
imagesc(stdMatrix)
title('Standard deviation for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar;
set(gca,'Fontsize',20)

subplot(2,2,3)
imagesc(stdMatrix)
title('Standard deviation for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

subplot(2,2,4)
imagesc(eventCountMatrix)
title('Blocking fraction for one business day')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

%% Without zeros 

for i = 1:length(serviceTimeMeans)
    for j = 1:length(interArrivalModes)
        for k = 1:N.numExperiments
            DONStruct{i,j}.O.queueTimesw0{k} = DONStruct{i,j}.O.queueTimes{k}(DONStruct{i,j}.O.queueTimes{k}~=0);
        end
        queueTimeStats{i,j}.meanVecw0 = cellfun(@mean, DONStruct{i,j}.O.queueTimesw0);
        queueTimeStats{i,j}.varVecw0 = cellfun(@var, DONStruct{i,j}.O.queueTimesw0);
        queueTimeStats{i,j}.medianVecw0 = cellfun(@median, DONStruct{i,j}.O.queueTimesw0);
    end
end
figure
meanMatrixw0 = NaN(numExperimentGridPoints);
stdMatrixw0 = NaN(numExperimentGridPoints);
medianMatrixw0 = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrixw0(i,j) = mean(queueTimeStats{i,j}.meanVecw0);
        stdMatrixw0(i,j) = mean(sqrt(queueTimeStats{i,j}.varVecw0));
        medianMatrixw0(i,j) = mean(queueTimeStats{i,j}.medianVecw0);
        eventCountMatrix(i,j) = mean(DONStruct{i,j}.O.blockedCounts./(DONStruct{i,j}.O.customerCounts));
    end
end

subplot(2,2,1)
imagesc(meanMatrixw0)
title('Mean queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
caxis([0,18])
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));


subplot(2,2,2)
imagesc((medianMatrix))
title('Median for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
caxis([0,18])
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

subplot(2,2,3)
imagesc(stdMatrix)
title('Standard deviation for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar;
set(gca,'Fontsize',20)

subplot(2,2,3)
imagesc(stdMatrix)
title('Standard deviation for queue time')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

subplot(2,2,4)
imagesc(eventCountMatrix)
title('Blocking fraction for one business day')
ylabel('Service time mean')
xlabel('Inter arrival mode')
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalModes','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeMeans','%2.2f'));

%% Histogram of queue times
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        combinedWaitTimes = [];
        for k = 1:length(DONStruct{i,j}.O.queueTimes)
            %tempQueueTimes = DONStruct{i,j}.O.queueTimes{k}';
            %tempQueueTimes = tempQueueTimes(tempQueueTimes~=0);
            combinedWaitTimes = [combinedWaitTimes, DONStruct{i,j}.O.queueTimes{k}];%+DONStruct{i,j}.O.serviceTimes{k}];
        end
        subplot(10,10,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        histogram(combinedWaitTimes,'Normalization','pdf')
        %plot(sort(combinedWaitTimes),(1:length(combinedWaitTimes))/length(combinedWaitTimes)) 
        xlim([0 40])
    end
end

%% Percentage of customers who wait less than X minutes
plot(combinedWaitTimes, (1:length(combinedWaitTimes)/length(combinedWaitTimes)))
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