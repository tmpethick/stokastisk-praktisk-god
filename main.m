%% Using servicetime = exponential, betweentime = exponential

maxPreSpace = 10000;
maxQueueLength = 10;
numServers = 10;
isCommonQueue = 1;  %1 for common, no of queues = servers
probManyItems = 0;

D = struct();
D.fewItemsDist = @() exprnd(20);            % mean service time for self
D.manyItemsDist = @() exprnd(50);          % mean service time for normal

% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

D.arrivalDist = @() exprnd(1);            % mean arrival time


numExperiments = 1;
blockedCounts = zeros(numExperiments,1);
eventCounts = zeros(numExperiments,1);
customerCounts = zeros(numExperiments,1);
maxT = 60*14*12;
burnInPeriod = 60*14;
queueTimes = cell(numExperiments,1);
rng(1);

for i=1:numExperiments

    lists = initialize(maxPreSpace, numServers, D,isCommonQueue);

    nextEvent = lists.events.next();
    
    % Simulating discrete event
    while (nextEvent.timeStamp < maxT)
        switch nextEvent.type
            case 'Arrival'
                [lists,block] = arrive(lists, D, nextEvent.timeStamp,...
                                        maxQueueLength,probManyItems);

                %Gathering statistical data
                if nextEvent.timeStamp > burnInPeriod
                    customerCounts(i) = customerCounts(i) + 1;
                else
                    block = 0;
                end                
            case 'Departure'
                [lists,queueTime] = depart(lists, nextEvent, D, nextEvent.timeStamp);
                queueTimes{i} = [queueTimes{i} queueTime];
        end
        %Saving statistical data
        
        blockedCounts(i) = blockedCounts(i) + block;
        block = 0;
        eventCounts(i) = eventCounts(i) + 1;

        nextEvent = lists.events.next();
    end
    disp(i)
end

disp(blockedCounts./customerCounts)
disp(mean(blockedCounts./customerCounts))
histogram(queueTimes{1}(queueTimes{1} ~= 0))