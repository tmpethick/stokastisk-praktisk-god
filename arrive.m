function [lists,block] = arrive(lists, serviceDist, arrivalDist, currentTime, maxQueueLength)    
%% Generate departure event or add to queue
    
    block = 0;
    if lists.servers.hasFreeServer()
        %Occupy server
        index = lists.servers.getFreeServer();
        lists.servers.occupyServer(index);

        %Raise departure event
        t = serviceDist();
        event = struct('type','Departure','timeStamp', currentTime + t);
        event.payload.serverIdx = index;       %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    else
        customer.timeStamp = currentTime;
        if lists.queue.tail-lists.queue.head >= maxQueueLength
            block = 1;
        else
            lists.queue.addToQueue(customer);
        end
    end
    
%% Generate arrival event
    t = arrivalDist();
    event = struct('type','Arrival','timeStamp', currentTime + t);
    lists.events.addToEventList(event);
end

