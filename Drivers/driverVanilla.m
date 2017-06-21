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

figure;
imagesc(meanMatrix)
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));


figure;
imagesc(stdMatrix)
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(medianMatrix)
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(eventCountMatrix)
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
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
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc((medianMatrixw0))
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

figure;
imagesc(stdMatrixw0)
set(gca,'Fontsize',16)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
colorbar
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

%% Difference for inter-arrival means
figure;
for i = 1:numExperimentGridPoints
    plot(interArrivalMeans-interArrivalMeans(ceil(numExperimentGridPoints/2)),meanMatrix(i,:),'o-')
    legend_names{i} = strcat('Mode: ',num2str(serviceTimeModes(i)));
    hold on 
end
hold off
set(gca,'Fontsize',30)
legend(legend_names)
xlabel('\Delta Inter arrival mean')
ylabel('Mean queue time')

%% Difference for service time modes
figure;
for i = 1:numExperimentGridPoints
   plot(serviceTimeModes-serviceTimeModes(ceil(numExperimentGridPoints/2)),meanMatrix(:,i),'o-')
   legend_names{i} = strcat('Mean: ',num2str(interArrivalMeans(i)));
   hold on 
end
hold off
set(gca,'Fontsize',30)
legend(legend_names,'location','northwest')
xlabel('\Delta Service time mode')
ylabel('Mean queue time')
%% Histogram of queue times
probabilityLMax = zeros(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        %combinedWaitTimes = [];
        combinedQueueTimes = [];
        for k = 1:length(DONStruct{i,j}.O.queueTimes)
            %tempQueueTimes = DONStruct{i,j}.O.queueTimes{k}';
            %tempQueueTimes = tempQueueTimes(tempQueueTimes~=0);
            %combinedWaitTimes = [combinedWaitTimes, DONStruct{i,j}.O.queueTimes{k}+DONStruct{i,j}.O.serviceTimes{k}];
            combinedQueueTimes = [combinedQueueTimes, DONStruct{i,j}.O.queueTimes{k}];
        end
        %probabilityLMax(i,j) = sum(combinedQueueTimes>5)/length(combinedQueueTimes);
        subplot(numExperimentGridPoints,numExperimentGridPoints,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        histogram(combinedQueueTimes,'Normalization','pdf')
        %plot(sort(combinedWaitTimes),(1:length(combinedWaitTimes))/length(combinedWaitTimes)) 
        %histogram(combinedWaitTimes,'Normalization','pdf')
        %plot(sort(combinedQueueTimes),(1:length(combinedQueueTimes))/length(combinedQueueTimes)) 
        xlim([0 40])
        %grid on
    end
end
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 ... 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, 0.02,'\bf Inter arrival time mean','HorizontalAlignment'... 
,'center','VerticalAlignment', 'bottom','Fontsize',32)


yAxisText = text(0.1, 0.5,'\bf Service time mode','HorizontalAlignment'... 
,'center','VerticalAlignment', 'bottom','Fontsize',32);
set(yAxisText, 'rotation', 90)
%%
imagesc(probabilityLMax)
colorbar;
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
set(gca,'Fontsize',16)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));
%% Server Efficiency plot

serverEfficiencyMatrix = zeros(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        %subplot(numExperimentGridPoints,numExperimentGridPoints,sub2ind([numExperimentGridPoints numExperimentGridPoints],j,i))
        %bar(mean(DONStruct{i,j}.O.serversOccupiedTimes)/DONStruct{i,j}.N.maxT)
        %ylim([0,1])
        %xlabel('Server index')
        %ylabel('Server efficiency')

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
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
set(gca,'Fontsize',16)
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));

%% ONLY RUN WHEN COMMON QUEUE DATA IS LOADED
meanMatrixCommon = meanMatrix;
stdMatrixCommon = stdMatrix;
confIntMeanCommon = confIntMean;
%% ONLY RUN WHEN NOT COMMON QUEUE DATA IS LOADED
meanMatrixNotCommon = meanMatrix;
stdMatrixNotCommon = stdMatrix;
confIntMeanNotCommon = confIntMean;
%% Difference between common and not common queue
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
set(gca,'Fontsize',23)
colormap(bone)
hold on 
plot(1:1,1:1,'black','LineWidth',3)
plot(1:1,1:1,'color',[0.5 0.5 0.5],'LineWidth',3)
plot(1:1,1:1,'white','LineWidth',3)
ylabel('Service time mode') 
xlabel('Inter arrival time mean') 
legend({'CQ better','Diff. not significant','NCQ better'},'FontSize',25,'location','southoutside')
set(gca,'xtick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'ytick',linspace(1,numExperimentGridPoints,numExperimentGridPoints));
set(gca,'XTickLabel',num2str(interArrivalMeans','%2.2f'));
set(gca,'yTickLabel',num2str(serviceTimeModes','%2.2f'));
axis image