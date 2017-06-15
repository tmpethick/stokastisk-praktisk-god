%% Using servicetime = exponential, betweentime = exponential

maxPreSpace = 10000;
maxQueueLength = 0;
numServers = 10;
isCommonQueue = 1;  %Set to for a single common queue. Set to 0 for many queues, i.e. one queue for each server
probManyItems = 0;

D = struct();
D.fewItemsDist = @() exprnd(8);            % mean service time for self
D.manyItemsDist = @() exprnd(1);          % mean service time for normal

% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05


D.arrivalDist = @() exprnd(1);            % mean inter arrival time


numExperiments = 10;
blockedCounts = zeros(numExperiments,1);
eventCounts = zeros(numExperiments,1);
serversOccupiedTimes = zeros(numExperiments, numServers);
customerCounts = zeros(numExperiments,1);
%The store is open for 14 hours
maxT = 60*14*12;
% Burn in period of 1 hour
burnInPeriod = 60*14;
queueTimes = cell(numExperiments,1);
rng(1);

for i=1:numExperiments

    lists = initialize(maxPreSpace, numServers, D,isCommonQueue);

    nextEvent = lists.events.next();
    countStabilizer = 0;
    % Simulating discrete event
    while (nextEvent.timeStamp < maxT)
        
        if countStabilizer > 20 && maxQueueLength ~= 0
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
                
                %Gathering statistical data (queue times and occupied times
                %for servers)
                queueTimes{i} = [queueTimes{i} queueTime];
                
                if nextEvent.timeStamp > burnInPeriod
                    serverIdx = nextEvent.payload.serverIdx;
                    serversOccupiedTimes(i, serverIdx) = ...
                                                         serversOccupiedTimes(i, serverIdx) + ...
                                                         lists.servers.timeOccupied(serverIdx);
                end

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
%%
% Print blocking fractions for all experiments and mean blocking fraction
disp((blockedCounts./customerCounts)')
disp(' ')
disp(mean(blockedCounts./customerCounts))

subplot(1,2,1)
histogram(queueTimes{1}(queueTimes{1} ~= 0))
title('Histogram of queue times')
xlabel('Queue time (minutes)')
ylabel('Frequency')
set(gca,'Fontsize',14)
subplot(1,2,2)
bar(serversOccupiedTimes(1,:)/maxT)
title('Bar plot of "server efficiency"')
ylim([0 1])
xlabel('Server index')
ylabel('Occupied time / total time')
set(gca,'Fontsize',14)