function [lists,queueTime] = depart(lists, event, D, currentTime)

%% Freeing up the server
    lists.servers.freeServer(event.payload.serverIdx);
%% Draw from queue

    queueTime = 0;
    if ~lists.queue.isQueueEmpty(event.payload.serverIdx)
        % Draw service time from distribution
        customer = lists.queue.drawFromQueue(event.payload.serverIdx);
        if customer.type == 1
            serviceTime = D.manyItemsDist();
        else
            serviceTime = D.fewItemsDist();
        end
        
        %Occupy server        
        queueTime = currentTime - customer.timeStamp;
        lists.servers.occupyServer(event.payload.serverIdx, serviceTime);

        %Raise departure event
        newEvent = struct('type','Departure','timeStamp', currentTime + serviceTime);
        newEvent.payload.serverIdx = event.payload.serverIdx;    %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(newEvent);
    end
    
end

