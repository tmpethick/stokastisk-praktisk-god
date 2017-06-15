%% Using servicetime = exponential, betweentime = exponential

maxPreSpace = 10000;
maxQueueLength = 4;
numServers = 10;
isCommonQueue = 0;  %1 for common, no of queues = servers
probManyItems = 0;

D = struct();
D.fewItemsDist = @() exprnd(8);            % mean service time for self
D.manyItemsDist = @() exprnd(50);          % mean service time for normal

% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

D.arrivalDist = @() exprnd(0.5);            % mean arrival time


numExperiments = 10;
blockedCounts = zeros(numExperiments,1);
eventCounts = zeros(numExperiments,1);
customerCounts = zeros(numExperiments,1);
maxT = 60*14;
burnInPeriod = 60;
queueTimes = cell(numExperiments,1);
rng(1);

for i=1:numExperiments

    lists = initialize(maxPreSpace, numServers, D,isCommonQueue);

    nextEvent = lists.events.next();
    countStabilizer = 0;
    % Simulating discrete event
    while (nextEvent.timeStamp < maxT)
        
        if countStabilizer > 20
        countStabilizer = 0;
        if max(lists.queue.getQueueSizes()) > 0.7*maxQueueLength && sum(lists.breakOn) >= 1
            event = struct('type','BreakOff','timeStamp', nextEvent.timeStamp+eps);
            lists.events.addToEventList(event);
            disp('BreakOff')
        end
        if max(lists.queue.getQueueSizes()) < 1 && sum(lists.breakOn)< numServers-1
            event = struct('type','BreakOn','timeStamp', nextEvent.timeStamp+eps);
            lists.events.addToEventList(event);
            disp('BreakOn')
        end
        end
        disp(lists.queue.getQueueSizes())
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
            case 'BreakOn'
                idx = find(lists.breakOn==0);
                lists.breakOn(idx(1)) = 1;
            case 'BreakOff'
                idx = find(lists.breakOn==1);
                lists.breakOn(idx(1)) = 0;
                
        end
        
        %Saving statistical data
        
        blockedCounts(i) = blockedCounts(i) + block;
        block = 0;
        eventCounts(i) = eventCounts(i) + 1;

        nextEvent = lists.events.next();
        countStabilizer = countStabilizer + 1;
    end
    disp(i)
end

disp(blockedCounts./customerCounts)
disp(mean(blockedCounts./customerCounts))
histogram(queueTimes{1}(queueTimes{1} ~= 0))