function [lists,block] = arrive(lists, D, P, currentTime, maxQueueLength)    
%% Generate departure event or add to queue
    
    block = 0;
    if sum(lists.servers.occupied) < length(lists.servers.occupied)
        %Occupy server
        index = find(lists.servers.occupied == 0);
        index = index(1);
        lists.servers.occupied(index) = 1;
        
        %Raise departure event
        event.type = 'Departure';
        t = serviceTime(D.sDist, P);
        event.timeStamp = currentTime + t;
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
    event.type = 'Arrival';
    t = arrivalTime(D.aDist, P);
    event.timeStamp = currentTime + t;
    lists.events.addToEventList(event);
end

