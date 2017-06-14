%% Using servicetime = exponential, betweentime = exponential

maxPreSpace = 10000;
maxQueueLength = 0;
servers = 10;
D.aDist = 'Exponential';
D.sDist = 'Exponential';
P.mu_a = 1; %mean time between customers
P.mu_s = 8; %mean service time
P.erlang = 3;
P.pareto = [1, 2.05];
P.constant = 1;
numExperiments = 1;
blockedCounts = zeros(numExperiments,1);
eventCounts = zeros(numExperiments,1);
customerCounts = zeros(numExperiments,1);
maxT = 60*14*12;
burnInPeriod = 60*14;

for i=1:numExperiments
    
    lists = initialize(maxPreSpace, servers, D, P);
    nextEvent = lists.events.next();
    
    % Simulating discrete event
    while (nextEvent.timeStamp < maxT)
        switch nextEvent.type
            case 'Arrival'
                [lists,block] = arrive(lists, D, P, nextEvent.timeStamp,...
                    maxQueueLength);

                %Gathering statistical data
                if nextEvent.timeStamp > burnInPeriod
                    customerCounts(i) = customerCounts(i) + 1;
                else
                    block = 0;
                end                
            case 'Departure'
                lists = depart(lists, nextEvent, D, P, nextEvent.timeStamp);
        end
        
        %Saving statistical data
        blockedCounts(i) = blockedCounts(i) + block;
        block = 0;
        eventCounts(i) = eventCounts(i) + 1;

        nextEvent = lists.events.next();
    end
    disp(i)
end
