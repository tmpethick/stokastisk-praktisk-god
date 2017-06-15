function [lists] = initialize(maxPreSpace, numServers, D, isCommonQueue)
%% Creating max-size event list
    lists.events = eventList(2*maxPreSpace);
    
    
%% Preparing first event
    event.type = 'Arrival';
    event.timeStamp = D.arrivalDist();
    lists.events.addToEventList(event);

%% Preparing breaks
    lists.breakOn = zeros(numServers,1);
%% Preparing servers availability
    lists.servers = serverList(numServers);
%% Preparing queue list
    lists.queue = queueList(maxPreSpace, isCommonQueue, numServers);
end

