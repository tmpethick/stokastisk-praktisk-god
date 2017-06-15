function [lists] = initialize(maxPreSpace, servers, D)
%% Creating max-size event list
    lists.events = eventList(2*maxPreSpace);
    
    
%% Preparing first event
    event.type = 'Arrival';
    event.timeStamp = D.arrivalDist();
    lists.events.addToEventList(event);
    
%% Preparing servers availability
    lists.servers = serverList(servers);

%% Preparing queue list
    lists.queue = queueList(maxPreSpace);
end

