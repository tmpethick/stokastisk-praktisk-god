%Compute stats
load('Drivers/driverVanillaData/Sensitivity-CQ1.mat')
numExperiments = DONStruct{1,1}.N.numExperiments;
NC = 10;
statsCell = cell(numExperimentGridPoints,numExperimentGridPoints,2);
f = @(M,idx) M(idx);
for k = 1:2
    for i = 1:numExperimentGridPoints
        for j = 1:numExperimentGridPoints
            statsCell{i,j,k} = struct();
            if k ==1
                statsCell{i,j,k}.serviceTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.serviceTimes), 1:NC);
                statsCell{i,j,k}.queueTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.queueTimes), 1:NC);
            elseif k==2
                statsCell{i,j,k}.serviceTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.serviceTimes), (NC+1):numExperiments);
                statsCell{i,j,k}.queueTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.queueTimes), (NC+1):numExperiments);
            end
        end
    end
end
%% Perform variance reduction on estimates of mean queue time using control variates
Z = cell(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        XCEst = statsCell{i,j,1}.queueTimeStats.meanVec;
        YCEst = statsCell{i,j,1}.serviceTimeStats.meanVec;
        covXY   = mean(XCEst.*YCEst) - mean(XCEst)*mean(YCEst);
        corrVec(i,j) = corr(XCEst,YCEst);
        VarY    = mean(YCEst.^2) - mean(YCEst)^2;
        muY     = mean(YCEst);
        c       = -covXY/VarY;
        X = statsCell{i,j,2}.queueTimeStats.meanVec;
        Y = statsCell{i,j,2}.serviceTimeStats.meanVec;
        Z{i,j} = X + c*(Y-muY);
    end
end

%% Difference between common and not common queue
meanMatrix = NaN(numExperimentGridPoints);
confIntMean = NaN(numExperimentGridPoints,numExperimentGridPoints,2);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(Z{i,j});
        confIntMean(i,j,:) = confInt(Z{i,j},0.05);    
    end
end
meanMatrixCommon = meanMatrix;
confIntMeanCommon = confIntMean;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             Repeat             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Compute stats
load('Drivers/driverVanillaData/Sensitivity-CQ0.mat')
numExperiments = DONStruct{1,1}.N.numExperiments;
NC = 10;
statsCell = cell(numExperimentGridPoints,numExperimentGridPoints,2);
f = @(M,idx) M(idx);
for k = 1:2
    for i = 1:numExperimentGridPoints
        for j = 1:numExperimentGridPoints
            statsCell{i,j,k} = struct();
            if k ==1
                statsCell{i,j,k}.serviceTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.serviceTimes), 1:NC);
                statsCell{i,j,k}.queueTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.queueTimes), 1:NC);
            elseif k==2
                statsCell{i,j,k}.serviceTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.serviceTimes), (NC+1):numExperiments);
                statsCell{i,j,k}.queueTimeStats.meanVec = f(cellfun(@mean, DONStruct{i,j}.O.queueTimes), (NC+1):numExperiments);
            end
        end
    end
end
%% Perform variance reduction on estimates of mean queue time using control variates
Z = cell(numExperimentGridPoints);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        XCEst = statsCell{i,j,1}.queueTimeStats.meanVec;
        YCEst = statsCell{i,j,1}.serviceTimeStats.meanVec;
        covXY   = mean(XCEst.*YCEst) - mean(XCEst)*mean(YCEst);
        corrVec(i,j) = corr(XCEst,YCEst);
        VarY    = mean(YCEst.^2) - mean(YCEst)^2;
        muY     = mean(YCEst);
        c       = -covXY/VarY;
        X = statsCell{i,j,2}.queueTimeStats.meanVec;
        Y = statsCell{i,j,2}.serviceTimeStats.meanVec;
        Z{i,j} = X + c*(Y-muY);
    end
end

%% Difference between common and not common queue
meanMatrix = NaN(numExperimentGridPoints);
confIntMean = NaN(numExperimentGridPoints,numExperimentGridPoints,2);
for i = 1:numExperimentGridPoints
    for j = 1:numExperimentGridPoints
        meanMatrix(i,j) = mean(Z{i,j});
        confIntMean(i,j,:) = confInt(Z{i,j},0.05);    
    end
end
meanMatrixNotCommon = meanMatrix;
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
set(gca,'Fontsize',20)
axis image