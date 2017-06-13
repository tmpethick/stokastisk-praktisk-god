classdef queueList < handle
%% Properties
    properties
        list %list
        head %leading index
        tail %trailing index
    end
    
%% Methods
    methods
        function empty = isQueueEmpty(obj)
            empty = (obj.head == obj.tail);
        end
        
        function customer = drawFromQueue(obj)            
            customer = obj.list(obj.head);
            obj.head = obj.head + 1;
        end
        
        function obj = addToQueue(obj, customer)
            obj.list{obj.tail} = customer;
            obj.tail = obj.tail + 1;
        end
        
        % Constructor
        function obj = queueList(maxLength)
            obj.list = cell(maxLength,1);
        end
    end
    
end

