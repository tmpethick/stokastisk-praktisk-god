function [lists] = initialize(n, servers, D, P)
%% Creating max-size event list
    lists.events = eventList(2*n);
    
    
%% Preparing first event
    event.type = 'Arrive';
    event.timeStamp = arrivalTime(D.aDist, P);
    lists.events.list{1} = event;
    
%% Preparing servers availability
    lists.servers = serverList(servers);

%% Preparing queue list
    lists.queue = queueList(n);
end

