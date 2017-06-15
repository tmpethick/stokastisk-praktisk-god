classdef queueList < handle
%% Properties
    properties
        list %list
        head %leading index
        tail %trailing index
        isCommonQueue
    end
    
%% Methods
    methods
        function queueIdx = getQueueIndex(obj, serverIdx)
            if obj.isCommonQueue
                queueIdx = 1;
            else
                queueIdx = serverIdx;
            end
        end
        
        function empty = isQueueEmpty(obj, serverIdx)
            queueIdx = obj.getQueueIndex(serverIdx);
            empty = (obj.head(queueIdx) == obj.tail(queueIdx));
        end
        
        function customer = drawFromQueue(obj, serverIdx)
            queueIdx = obj.getQueueIndex(serverIdx);
            customer = obj.list{obj.head(queueIdx)};
            obj.head(queueIdx) = obj.head(queueIdx) + 1;
        end
        
        function obj = addToQueue(obj, customer, serverIdx)
            queueIdx = obj.getQueueIndex(serverIdx);
            obj.list{obj.tail(queueIdx)} = customer;
            obj.tail(queueIdx) = obj.tail(queueIdx) + 1;
        end
        
        function size = getQueueSizes(obj)
            size = obj.tail-obj.head;
        end
        
        % Constructor
        function obj = queueList(maxLength, isCommonQueue, numServers)
            if isCommonQueue
                obj.list = cell(maxLength, 1);
                obj.head = 1;
                obj.tail = 1;
            elseif ~isCommonQueue
                obj.list = cell(maxLength, numServers);           
                obj.head = ones(numServers,1);
                obj.tail = ones(numServers,1);
            end
            
            obj.isCommonQueue = isCommonQueue;
        end
    end
    
end

