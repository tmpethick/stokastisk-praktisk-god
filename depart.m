function [lists] = depart(lists, event, serviceDist, arrivalDist, currentTime)
%% Freeing up the server
    lists.servers.setServer('Free', event.payload.server);
%% Draw from queue
    
    if ~lists.queue.isQueueEmpty()
        %Occupy server
        index = find(lists.servers.occupied == 0);
        index = index(1);
        lists.servers.setServer('Occupy', index);

        %Raise departure event
        t = serviceDist();
        event = struct('type','Departure','timeStamp', currentTime + t);
        event.payload.server = index;       %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    end
    
end

