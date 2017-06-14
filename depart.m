function [lists,queueTime] = depart(lists, event, serviceDist, arrivalDist, currentTime)
%% Freeing up the server
    lists.servers.freeServer(event.payload.serverIdx);
%% Draw from queue
    queueTime = 0;
    if ~lists.queue.isQueueEmpty()
        %Occupy server
        customer = lists.queue.drawFromQueue();
        queueTime = currentTime - customer.timeStamp;
        lists.servers.occupyServer(event.payload.serverIdx);

        %Raise departure event
        t = serviceDist();
        event = struct('type','Departure','timeStamp', currentTime + t);
        event.payload.serverIdx = index;    %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    end
    
end

