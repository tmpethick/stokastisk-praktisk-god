function [lists,block] = arrive(lists, selfServiceDist,normalServiceDist,...
                                arrivalDist, currentTime, maxQueueLength,...
                                probNormalService)    
%% Generate departure event or add to queue
    
    block = 0;
    if sum(lists.servers.occupied) < length(lists.servers.occupied)
        %Occupy server
        index = find(lists.servers.occupied == 0);
        index = index(1);
        lists.servers.setServer('Occupy', index);
        
        %Raise departure event
        indicator = binornd(1,probNormalService,1,1)
        if indicator == 1
            t = normalServiceDist();
        else
            t = selfServiceDist();
        end
        event = struct('type','Departure','timeStamp', currentTime + t);
        event.payload.server = index;       %Payload is associated data. Server index is used to free up server in departure events
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

