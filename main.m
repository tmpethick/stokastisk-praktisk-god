%% Using servicetime = exponential, betweentime = exponential

maxPreSpace = 10000;
maxQueueLength = 0;
servers = 10;

serviceDist = @() exprnd(8);            % mean service time
% serviceDist = @() 1;                  % constant
% serviceDist = @() 1*rand^(-1/2.05);   % pareto beta=1, k=2.05

arrivalDist = @() exprnd(1);            % mean arrival time

numExperiments = 10;
blockedCounts = zeros(numExperiments,1);
eventCounts = zeros(numExperiments,1);
customerCounts = zeros(numExperiments,1);
maxT = 60*14*12;
burnInPeriod = 60*14;

for i=1:numExperiments
    
    lists = initialize(maxPreSpace, servers, serviceDist, arrivalDist);
    nextEvent = lists.events.next();
    
    % Simulating discrete event
    while (nextEvent.timeStamp < maxT)
        switch nextEvent.type
            case 'Arrival'
                [lists,block] = arrive(lists, serviceDist, arrivalDist, nextEvent.timeStamp,...
                    maxQueueLength);

                %Gathering statistical data
                if nextEvent.timeStamp > burnInPeriod
                    customerCounts(i) = customerCounts(i) + 1;
                else
                    block = 0;
                end                
            case 'Departure'
                lists = depart(lists, nextEvent, serviceDist, arrivalDist, nextEvent.timeStamp);
        end
        
        %Saving statistical data
        blockedCounts(i) = blockedCounts(i) + block;
        block = 0;
        eventCounts(i) = eventCounts(i) + 1;

        nextEvent = lists.events.next();
    end
    disp(i)
end
