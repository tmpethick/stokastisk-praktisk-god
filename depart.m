function [lists] = depart(lists, event, D, P, currentTime)
%% Freeing up the server
    lists.servers.setServer('Free', event.payload.server);
%% Draw from queue
    
    if ~lists.queue.isQueueEmpty()
        %Occupy server
        index = find(lists.servers.occupied == 0);
        index = index(1);
        lists.servers.list(index) = 1;
        
        %Raise departure event
        event.type = 'Departure';
        t = serviceTime(D.sDist, P);
        event.timeStamp = currentTime + t;
        event.payload.server = index;       %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    end
    
end

