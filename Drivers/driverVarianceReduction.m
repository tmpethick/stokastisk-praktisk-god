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
N.isCommonQueue     = 0;
N.maxQueueLength    = 5;
% Adjust max queue size such that common queue and no common queue
% scenarios are comparable
if N.isCommonQueue
    N.maxQueueLength = N.maxQueueLength*N.maxServers;
end
N.numExperiments    = 500;
N.maxT              = 60*14;
N.burnInPeriod      = 0;
N.breakThresholds   = [0.7 1];
N.printProgress     = true;

D               = struct();
D.fewItemsDist  = @() PertDist(1/4,1.5,12,[],1,10);        % mean service time for self-service
D.manyItemsDist = @() exprnd(1);        % mean service time for normal service
D.arrivalDist   = @() exprnd(1.4);     % mean inter arrival time
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function
serviceTimeModes = 1.5;
interArrivalMeans = 1.4;
% Number of experiments used to estimate the constant c fro control
% variates
numEstCExp = 40;
% No more than 50% of the experiments may be used to estimate c
assert(2*N.numExperiments>=numEstCExp);

serviceTimeStats = struct();
queueTimeStats = struct();
waitTimeStats = struct();
DONStruct = struct();
D.fewItemsDist  = @() PertDist(1/4,serviceTimeModes,12,[],1,10);
D.arrivalDist   = @() exprnd(interArrivalMeans);
%Run experiment
O = main(D, N);
DONStruct.D = D;
%Struct OC contains data used to estimate c for control variates
DONStruct.OC = structfun(@(M) M(1:numEstCExp,:),O,'Uniform',false);
%Struct O contains the rest of the data
DONStruct.O = structfun(@(M) M((numEstCExp+1):end,:),O,'Uniform',false);
DONStruct.N = N;

%Compute stats
% Add extra column to queueTimeStats.meanVec and serviceTimeStats.meanVec
% for purpose of variance reduction
statsCell = {struct(), struct()};
OCAndOCell = {DONStruct.OC, DONStruct.O}; 

for i = 1:2
    statsCell{i}.serviceTimeStats.meanVec = cellfun(@mean, OCAndOCell{i}.serviceTimes);
    statsCell{i}.serviceTimeStats.varVec = cellfun(@var, OCAndOCell{i}.serviceTimes);
    statsCell{i}.serviceTimeStats.medianVec = cellfun(@median, OCAndOCell{i}.serviceTimes);
    statsCell{i}.queueTimeStats.meanVec = cellfun(@mean, OCAndOCell{i}.queueTimes);
    statsCell{i}.queueTimeStats.varVec = cellfun(@var, OCAndOCell{i}.queueTimes);
    statsCell{i}.queueTimeStats.medianVec = cellfun(@median, OCAndOCell{i}.queueTimes);
    %statsCell{i}.waitTime = cellfun(@plus, OCAndOCell{i}.queueTimes, OCAndOCell{i}.serviceTimes,'Un',false);
    %statsCell{i}.waitTimeStats.meanVec = cellfun(@mean,waitTime);
    %statsCell{i}.waitTimeStats.varVec = cellfun(@var,waitTime);
    %statsCell{i}.waitTimeStats.medianVec = cellfun(@median,waitTime);
end
%%
clear D i j O N
c = clock;
%save(sprintf('Drivers/driverVanillaData/varianceReductionST-%d-%d-%d-%d-%d',c(1),c(2),c(3),c(4),c(5)))

%% Perform variance reduction on estimates of mean queue time using control variates
XCEst = statsCell{1}.queueTimeStats.meanVec;
YCEst = statsCell{1}.serviceTimeStats.meanVec;
covXY   = mean(XCEst.*YCEst) - mean(XCEst)*mean(YCEst);
corrVec(1) = corr(XCEst,YCEst);
VarY    = mean(YCEst.^2) - mean(YCEst)^2;
muY     = mean(YCEst);
c       = -covXY/VarY;
%%
X = statsCell{2}.queueTimeStats.meanVec;
Y = statsCell{2}.serviceTimeStats.meanVec;
Z = X + c*(Y-muY);

%% Plot mean, standard deviation, median and blocking fraction 
meanMatrix = NaN(numExperimentGridPoints);
stdMatrix = NaN(numExperimentGridPoints);
medianMatrix = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(queueTimeStats.meanVec);
        stdMatrix(i,j) = mean(sqrt(queueTimeStats.varVec));
        medianMatrix(i,j) = mean(queueTimeStats.medianVec);
        eventCountMatrix(i,j) = mean(DONStruct.O.blockedCounts./(DONStruct.O.customerCounts));
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
        for k = 1:(DONStruct.N.numExperiments)
            DONStruct.O.queueTimesw0{k} = DONStruct.O.queueTimes{k}(DONStruct.O.queueTimes{k}~=0);
        end
        queueTimeStats.meanVecw0 = cellfun(@mean, DONStruct.O.queueTimesw0);
        queueTimeStats.varVecw0 = cellfun(@var, DONStruct.O.queueTimesw0);
        queueTimeStats.medianVecw0 = cellfun(@median, DONStruct.O.queueTimesw0);
    end
end
meanMatrixw0 = NaN(numExperimentGridPoints);
stdMatrixw0 = NaN(numExperimentGridPoints);
medianMatrixw0 = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrixw0(i,j) = mean(queueTimeStats.meanVecw0);
        stdMatrixw0(i,j) = mean(sqrt(queueTimeStats.varVecw0));
        medianMatrixw0(i,j) = mean(queueTimeStats.medianVecw0);
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

%% Histogram of queue times
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        combinedWaitTimes = [];
        for k = 1:length(DONStruct.O.queueTimes)
            %tempQueueTimes = DONStruct.O.queueTimes{k}';
            %tempQueueTimes = tempQueueTimes(tempQueueTimes~=0);
            combinedWaitTimes = [combinedWaitTimes, DONStruct.O.queueTimes{k}];%+DONStruct.O.serviceTimes{k}];
        end
        %subplot(numExperimentGridPoints,numExperimentGridPoints,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        histogram(combinedWaitTimes,'Normalization','pdf')
        %plot(sort(combinedWaitTimes),(1:length(combinedWaitTimes))/length(combinedWaitTimes)) 
        xlim([0 20])
        grid on
    end
end

%% Server Efficiency plot
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        subplot(numExperimentGridPoints,numExperimentGridPoints,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        bar(mean(DONStruct.O.serversOccupiedTimes)/DONStruct.N.maxT)
        ylim([0,1])
        xlabel('Server index')
        ylabel('Server efficiency')
    end
end

%% Difference between common and not common queue
load('Drivers/driverVanillaData/Sensitivity-CQ1')
meanMatrix = NaN(numExperimentGridPoints);
confIntMean = NaN(numExperimentGridPoints,numExperimentGridPoints,2);
stdMatrix = NaN(numExperimentGridPoints);
medianMatrix = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(queueTimeStats{i,j}.meanVec);
        confIntMean(i,j,:) = confInt(queueTimeStats{i,j}.meanVec,0.05);
        stdMatrix(i,j) = mean(sqrt(queueTimeStats{i,j}.varVec));
        medianMatrix(i,j) = mean(queueTimeStats{i,j}.medianVec);
        eventCountMatrix(i,j) = mean(DONStruct{i,j}.O.blockedCounts./(DONStruct{i,j}.O.customerCounts));
    end
end
meanMatrixCommon = meanMatrix;
stdMatrixCommon = stdMatrix;
confIntMeanCommon = confIntMean;
%%
load('Drivers/driverVanillaData/Sensitivity-CQ0')
meanMatrix = NaN(numExperimentGridPoints);
confIntMean = NaN(numExperimentGridPoints,numExperimentGridPoints,2);
stdMatrix = NaN(numExperimentGridPoints);
medianMatrix = NaN(numExperimentGridPoints);
eventCountMatrix = NaN(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(queueTimeStats{i,j}.meanVec);
        confIntMean(i,j,:) = confInt(queueTimeStats{i,j}.meanVec,0.05);
        stdMatrix(i,j) = mean(sqrt(queueTimeStats{i,j}.varVec));
        medianMatrix(i,j) = mean(queueTimeStats{i,j}.medianVec);
        eventCountMatrix(i,j) = mean(DONStruct{i,j}.O.blockedCounts./(DONStruct{i,j}.O.customerCounts));
    end
end
meanMatrixNotCommon = meanMatrix;
stdMatrixNotCommon = stdMatrix;
confIntMeanNotCommon = confIntMean;
%%
clearvars -except numExperimentGridPoints meanMatrixCommon stdMatrixCommon...
    confIntMeanCommon meanMatrixNotCommon stdMatrixNotCommon ...
    confIntMeanNotCommon interArrivalMeans serviceTimeModes
diffMatrix = (meanMatrixCommon-meanMatrixNotCommon)./meanMatrixCommon;
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        if confIntMeanCommon(i,j,1) > confIntMeanNotCommon(i,j,2)
            diffMatrix(i,j) = 1;
        elseif confIntMeanCommon(i,j,2) < confIntMeanNotCommon(i,j,1)
            diffMatrix(i,j) = -1;
        else
            diffMatrix(i,j) = 0;
        end
    end
    
end

imagesc(diffMatrix)
colormap(bone)
hold on 
plot(1:1,1:1,'black','LineWidth',3)
plot(1:1,1:1,'color',[0.5 0.5 0.5],'LineWidth',3)
plot(1:1,1:1,'white','LineWidth',3)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
legend({'CQ better','Diff. not significant','NCQ better'},'FontSize',16,'location','southoutside')
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));
axis image