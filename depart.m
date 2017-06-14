function [lists,queueTime] = depart(lists, event, serviceDist, currentTime)
%% Freeing up the server
    lists.servers.freeServer(event.payload.serverIdx);
%% Draw from queue
    queueTime = 0;
    if ~lists.queue.isQueueEmpty(event.payload.serverIdx)
        %Occupy server        
        customer = lists.queue.drawFromQueue(event.payload.serverIdx);
        queueTime = currentTime - customer.timeStamp;
        lists.servers.occupyServer(event.payload.serverIdx);

        %Raise departure event
        t = serviceDist();
        newEvent = struct('type','Departure','timeStamp', currentTime + t);
        newEvent.payload.serverIdx = event.payload.serverIdx;
        lists.events.addToEventList(newEvent);
    end
    
end

