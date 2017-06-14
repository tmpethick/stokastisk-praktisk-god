function [lists,queueTime] = depart(lists, event, serviceDist, arrivalDist, currentTime)
%% Freeing up the server
    lists.servers.setServer('Free', event.payload.server);
%% Draw from queue
    queueTime = 0;
    if ~lists.queue.isQueueEmpty()
        %Occupy server
        customer = lists.queue.drawFromQueue();
        queueTime = currentTime - customer.timeStamp;
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

