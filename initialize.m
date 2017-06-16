function [lists] = initialize(maxPreSpace, initialServers, maxServers, D, isCommonQueue)
%% Creating max-size event list
    lists.events = eventList(2*maxPreSpace);
    
    
%% Preparing first event
    event.type = 'Arrival';
    event.timeStamp = D.arrivalDist();
    lists.events.addToEventList(event);

%% Preparing breaks
    lists.breakOn = zeros(maxServers,1);
    lists.breakOn(1:initialServers) = 1;
    
%% Preparing servers availability
    lists.servers = serverList(maxServers);
%% Preparing queue list
    lists.queue = queueList(maxPreSpace, isCommonQueue, maxServers);
end

