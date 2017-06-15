function [lists,queueTime] = depart(lists, event, D, currentTime,probManyItems)
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
        if customer.type == 1
            t = D.manyItemsDist();
        else
            t = D.fewItemsDist();
        end
        newEvent = struct('type','Departure','timeStamp', currentTime + t);
        newEvent.payload.serverIdx = event.payload.serverIdx;    %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(newEvent);
    end
    
end

