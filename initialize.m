function [lists] = initialize(maxPreSpace, servers, D, P)
%% Creating max-size event list
    lists.events = eventList(2*maxPreSpace);
    
    
%% Preparing first event
    event.type = 'Arrival';
    event.timeStamp = arrivalTime(D.aDist, P);
    lists.events.list{1} = event;
    
%% Preparing servers availability
    lists.servers = serverList(servers);

%% Preparing queue list
    lists.queue = queueList(maxPreSpace);
end

