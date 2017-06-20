%% Set parameters
N = struct();
N.maxPreSpace       = 100000;
N.maxQueueLength    = 10;
N.initialServers    = 10;
N.maxServers        = 10;
%Set commonQueue to 1 for a single common queue. Set to 0 for many queues, 
% i.e. one queue for each server
N.isCommonQueue     = 0;
N.probManyItems     = 0;
N.numExperiments    = 1;
N.maxT              = 60*14*12;
N.burnInPeriod      = 60*14;
N.breakThresholds   = [0.7 1];
N.isBreakPossible   = false;
N.printProgress     = true;

arrivalIntensity            = 1;
meanServiceTimeFewItems     = 8;
meanServiceTimeManyItems    = 8;

D               = struct();
D.fewItemsDist  = @() exprnd(meanServiceTimeFewItems); 
D.manyItemsDist = @() exprnd(meanServiceTimeManyItems);        
D.arrivalDist   = @() exprnd(arrivalIntensity );
%D.fewItemsDist  = @() 8;  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

rng(1);

%% Call main function
queueTimes = zeros(11,1);
serviceTimes = zeros(11,1);
blockedCounts = zeros(11,1);
serverEfficiency = zeros(11,1);
Os = cell(11,1);
for i=1:11
    N.initialServers    = i + 4;
    N.maxServers        = i + 4;
    O = main(D, N);
    queueTimes(i)       = mean(O.queueTimes{1});
    serviceTimes(i)     = mean(O.serviceTimes{1});
    blockedCounts(i)    = O.blockedCounts(1) / O.customerCounts(1);
    serverEfficiency(i) = mean(O.serversOccupiedTimes(1,:)/(N.maxT - N.burnInPeriod));
    Os{i} = O;
    
    disp(blockedCounts(i))
    disp(queueTimes(i))
    disp(serviceTimes(i))
end

%% Plot

figure
blue        = [161/255 202/255 241/255];
red         = [250/255 128/255 114/255];
green       = [0   1   0.1];
orange      = [1   0.7 0.4];
purple      = [0.7 0.6 1  ];

h(1) = subplot(2,2,1);
bar(5:15, queueTimes, 'FaceColor', blue)
set(gca,'fontsize',16)
ylabel('Queue Time')
xlabel('Number of servers')
h(2) = subplot(2,2,2);
bar(5:15, serviceTimes, 'FaceColor', red)
set(gca,'fontsize',16)
ylabel('Service Time')
xlabel('Number of servers')
h(3) = subplot(2,2,3);
bar(5:15, blockedCounts, 'FaceColor', orange)
set(gca,'fontsize',16)
ylabel('Blocking Fraction')
xlabel('Number of servers')
ylim([0,1])
% pos = get(h,'Position');
% new = mean(cellfun(@(v)v(1),pos(1:2)));
% set(h(3),'Position',[new,pos{end}(2:end)])
h(4) = subplot(2,2,4);
bar(5:15,serverEfficiency, 'FaceColor', purple)
set(gca,'fontsize',16)
xlabel('Number of servers')
ylim([0,1.03])
ylabel('Work load')


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
