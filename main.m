function O = main(D, N)
%% Input parameters
% D: Struct containing distribution functions
% N : Struct containing scalar and vector input parameters
if N.maxQueueLength==0 && N.isBreakPossible
    error('isBreaksPossible is true and maxQueueLength is 0. Breaks are not possible when maxQueueLength is 0.')
end

blockedCounts = zeros(N.numExperiments,1);
eventCounts = zeros(N.numExperiments,1);
serversOccupiedTimes = zeros(N.numExperiments, N.maxServers);
customerCounts = zeros(N.numExperiments,1);
queueTimes = cell(N.numExperiments,1);
serviceTimes = cell(N.numExperiments,1);
responseTimes = cell(N.numExperiments,1);
O.BreakOnTime = [];
O.BreakOffTime = [];

for i=1:(N.numExperiments)
    
    lists = initialize(N.maxPreSpace, N.initialServers, N.maxServers, D, N.isCommonQueue);
    
    nextEvent = lists.events.next();
    countStabilizer = 0;
    % Simulating discrete event
    while (nextEvent.timeStamp < N.maxT)

        if countStabilizer > 20 && N.maxQueueLength ~= 0 && N.isBreakPossible
            countStabilizer = 0;
            if max(lists.queue.getQueueSizes()) > N.breakThresholds(1)*N.maxQueueLength && sum(lists.breakOn) >= 1
                event = struct('type','BreakOff','timeStamp', nextEvent.timeStamp+eps);
                lists.events.addToEventList(event);
                O.BreakOffTime = [O.BreakOffTime nextEvent.timeStamp+eps];
            end
            if max(lists.queue.getQueueSizes()) < N.breakThresholds(2) && sum(lists.breakOn)< N.maxServers-1
                event = struct('type','BreakOn','timeStamp', nextEvent.timeStamp+eps);
                lists.events.addToEventList(event);
                O.BreakOnTime = [O.BreakOnTime nextEvent.timeStamp+eps];
            end
        end
        switch nextEvent.type
            case 'Arrival'
                [lists,block] = arrive(lists, D, nextEvent.timeStamp,...
                    N.maxQueueLength, N.probManyItems);
                
                %Gathering statistical data
                if nextEvent.timeStamp > N.burnInPeriod
                    customerCounts(i) = customerCounts(i) + 1;
                else
                    block = 0;
                end
                
            case 'Departure'
                [lists,queueTime] = depart(lists, nextEvent, D, nextEvent.timeStamp);
                
                if nextEvent.timeStamp > N.burnInPeriod
                    
                    %Gathering statistical data (queue times and occupied times
                    %for servers)
                    queueTimes{i} = [queueTimes{i} queueTime];
                    serviceTimes{i} = [serviceTimes{i} nextEvent.payload.serviceTime];
                    responseTimes{i} = [responseTimes{i} queueTime + nextEvent.payload.serviceTime];

                    serverIdx = nextEvent.payload.serverIdx;
                    serversOccupiedTimes(i, serverIdx) = ...
                        serversOccupiedTimes(i, serverIdx) + ...
                        lists.servers.timeOccupied(serverIdx);
                end
                
            case 'BreakOn'
                idx = find(lists.breakOn==0);
                lists.breakOn(idx(randi(length(idx)))) = 1; % Choose random server to put on break
            case 'BreakOff'
                idx = find(lists.breakOn==1);
                lists.breakOn(idx(randi(length(idx)))) = 0; % Choose random server to take off break
                
        end
        
        
        %Saving statistical data
        
        blockedCounts(i)    = blockedCounts(i) + block;
        block               = 0;
        eventCounts(i)      = eventCounts(i) + 1;
        nextEvent           = lists.events.next();
        countStabilizer     = countStabilizer + 1;
    end
    disp(i)
end

O = struct();
O.blockedCounts         = blockedCounts;
O.customerCounts        = customerCounts;
O.eventCounts           = eventCounts;
O.queueTimes            = queueTimes;
O.serversOccupiedTimes  = serversOccupiedTimes;
O.responseTimes         = responseTimes;
O.serviceTimes          = serviceTimes;

end