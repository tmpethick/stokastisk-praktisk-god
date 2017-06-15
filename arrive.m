function [lists,block,queueSizes] = arrive(lists, D, currentTime, maxQueueLength,...
                                probManyItems,customer)    
%% Generate departure event or add to queue
    customer.type = binornd(1,probManyItems,1,1);
    block = 0;
    if lists.servers.hasFreeServer()
        % Draw service time from distribution
        if customer.type == 1
            serviceTime = D.manyItemsDist();
        else
            serviceTime = D.fewItemsDist();
        end
        %Occupy server
        serverIdx = lists.servers.getFreeServer();
        lists.servers.occupyServer(serverIdx, serviceTime);

        %Raise departure event
        event = struct('type','Departure','timeStamp', currentTime + serviceTime);
        event.payload.serverIdx = serverIdx;       %Payload is associated data. Server index is used to free up server in departure events
        lists.events.addToEventList(event);
    else
        customer.timeStamp = currentTime;
        
        %Finding shortest queue (if there is no common queue)
        queueIdx = lists.queue.getFreeQueue(lists.breakOn);
        
        %Checking whether customer is blocked or added to queue
        if lists.queue.tail(queueIdx)-lists.queue.head(queueIdx) >= maxQueueLength
            block = 1;
        else
            lists.queue.addToQueue(customer, queueIdx);
        end
    end
    
%% Generate arrival event
    arrivalTime = D.arrivalDist();
    event = struct('type','Arrival','timeStamp', currentTime + arrivalTime);
    lists.events.addToEventList(event);
end

