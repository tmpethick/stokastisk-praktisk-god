function [lists] = initialize(maxPreSpace, numServers, nSelfService, arrivalDist, isCommonQueue)
%% Creating max-size event list
    lists.events = eventList(2*maxPreSpace);
    
    
%% Preparing first event
    event.type = 'Arrival';
    event.timeStamp = arrivalDist();
    lists.events.addToEventList(event);
    
%% Preparing servers availability
    lists.servers = serverList(servers,nSelfService);
%% Preparing queue list
    lists.queue = queueList(maxPreSpace, isCommonQueue, numServers);
end

