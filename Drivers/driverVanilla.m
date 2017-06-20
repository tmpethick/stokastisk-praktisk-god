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
D.fewItemsDist  = @() PertDist(1/4,1.5,12,[],1,10);        % mean service time for self-service
D.manyItemsDist = @() PertDist(1/4,1.5,12,[],1,10);        % mean service time for normal service
D.arrivalDist   = @() exprnd(1.4);     % mean inter arrival time
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function
numExperimentGridPoints = 9;
serviceTimeModes = linspace(1.5*0.7,1.5*1.3,numExperimentGridPoints);
interArrivalMeans = linspace(1.4*0.7, 1.4*1.3, numExperimentGridPoints);

serviceTimeStats = cell(numExperimentGridPoints);
queueTimeStats = cell(numExperimentGridPoints);
waitTimeStats = cell(numExperimentGridPoints);
DONStruct = cell(numExperimentGridPoints);
for i = 1:length(serviceTimeModes)
    for j = 1:length(interArrivalMeans)
        fprintf('i,j: %d, %d\n',i,j)
        D.fewItemsDist  = @() PertDist(1/4,serviceTimeModes(i),12,[],1,10);
        D.arrivalDist   = @() exprnd(interArrivalMeans(j));
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
save(sprintf('Drivers/driverVanillaData/driverVanillaExp-%d-%d-%d-%d-%d',c(1),c(2),c(3),c(4),c(5)))
%% Plot mean, standard deviation, median and blocking fraction 
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

figure;
imagesc(meanMatrix)
title('Mean queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));


figure;
imagesc(stdMatrix)
title('Standard deviation for queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(medianMatrix)
title('Median for queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(eventCountMatrix)
title('Blocking fraction for one business day')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

%% Plot mean, standard deviation and median without zeros

for i = 1:length(serviceTimeModes)
    for j = 1:length(interArrivalMeans)
        for k = 1:(DONStruct{i,j}.N.numExperiments)
            DONStruct{i,j}.O.queueTimesw0{k} = DONStruct{i,j}.O.queueTimes{k}(DONStruct{i,j}.O.queueTimes{k}~=0);
        end
        queueTimeStats{i,j}.meanVecw0 = cellfun(@mean, DONStruct{i,j}.O.queueTimesw0);
        queueTimeStats{i,j}.varVecw0 = cellfun(@var, DONStruct{i,j}.O.queueTimesw0);
        queueTimeStats{i,j}.medianVecw0 = cellfun(@median, DONStruct{i,j}.O.queueTimesw0);
    end
end
meanMatrixw0 = NaN(numExperimentGridPoints);
stdMatrixw0 = NaN(numExperimentGridPoints);
medianMatrixw0 = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrixw0(i,j) = mean(queueTimeStats{i,j}.meanVecw0);
        stdMatrixw0(i,j) = mean(sqrt(queueTimeStats{i,j}.varVecw0));
        medianMatrixw0(i,j) = mean(queueTimeStats{i,j}.medianVecw0);
    end
end

figure;
imagesc(meanMatrixw0)
title('Mean queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc((medianMatrixw0))
title('Median for queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(stdMatrixw0)
title('Standard deviation for queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

%% Difference for inter-arrival means

for i = 1:numExperimentGridPoints
    plot(interArrivalMeans-interArrivalMeans(ceil(numExperimentGridPoints/2)),meanMatrix(i,:),'*-')
    hold on
end
xlabel('Inter arrival mean')
ylabel('queue time')
%% Difference for service time modes
for i = 1:numExperimentGridPoints
   plot(serviceTimeModes-serviceTimeModes(ceil(numExperimentGridPoints/2)),meanMatrix(:,i),'*-')
   hold on 
end
xlabel('Service time mode')
ylabel('queue time')
%%
imagesc(cols)
colorbar;
title('Median for queue time')
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
set(gca,'Fontsize',12)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));
%% Histogram of queue times
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        combinedWaitTimes = [];
        for k = 1:length(DONStruct{i,j}.O.queueTimes)
            %tempQueueTimes = DONStruct{i,j}.O.queueTimes{k}';
            %tempQueueTimes = tempQueueTimes(tempQueueTimes~=0);
            combinedWaitTimes = [combinedWaitTimes, DONStruct{i,j}.O.queueTimes{k}];%+DONStruct{i,j}.O.serviceTimes{k}];
        end
        subplot(numExperimentGridPoints,numExperimentGridPoints,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        %histogram(combinedWaitTimes,'Normalization','pdf')
        plot(sort(combinedWaitTimes),(1:length(combinedWaitTimes))/length(combinedWaitTimes)) 
        xlim([0 20])
    end
end

%% Server Efficiency plot

serverEfficiencyMatrix = zeros(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanvec = mean(DONStruct{i,j}.O.serversOccupiedTimes/DONStruct{i,j}.N.maxT);
        if abs(meanvec(1) - meanvec(2)) > 0.02 % Difference larger than 2%
            disp(i)
            disp(j)
            disp(meanvec(1) - meanvec(2))
        end
        %subplot(10,10,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        %bar(mean(DONStruct{i,j}.O.serversOccupiedTimes)/DONStruct{i,j}.N.maxT)
        serverEfficiencyMatrix(i,j) = (mean(meanvec));
    end
end
imagesc(serverEfficiencyMatrix)
colorbar;
title('Server efficiency plot')