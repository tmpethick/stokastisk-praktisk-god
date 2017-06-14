function [lists,block] = arrive(lists, serviceDist, arrivalDist, currentTime, maxQueueLength)    
%% Generate departure event or add to queue
    
    block = 0;
    if lists.servers.hasFreeServer()
        %Occupy server
        serverIdx = lists.servers.getFreeServer();
        lists.servers.occupyServer(serverIdx);

        %Raise departure event
        t = serviceDist();
        event = struct('type','Departure','timeStamp', currentTime + t);
        event.payload.serverIdx = serverIdx;       %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    else
        customer.timeStamp = currentTime;
        
        %Finding shortest queue (if there is no common queue)
        if lists.queue.isCommonQueue
            queueIdx = 1;
        else
            queueSizes = lists.queue.tail-lists.queue.head;
            queueIdx = find(queueSizes == min(queueSizes));
            queueIdx = queueIdx(1);
        end
        
        %Checking whether customer is blocked or added to queue
        if lists.queue.tail(queueIdx)-lists.queue.head(queueIdx) >= maxQueueLength
            block = 1;
        else
            lists.queue.addToQueue(customer, queueIdx);
        end
    end
    
%% Generate arrival event
    t = arrivalDist();
    event = struct('type','Arrival','timeStamp', currentTime + t);
    lists.events.addToEventList(event);
end

