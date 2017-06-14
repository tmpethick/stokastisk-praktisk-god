classdef eventList < handle
%% Properties    
    properties
        heap
        eventMap
    end
    
%% Methods
    methods
        function event = next(obj)
            time = obj.heap.ExtractMin();
            event = obj.eventMap(time);
            obj.eventMap.remove(time);
        end
        
        
        function obj = addToEventList(obj, event)
            time = event.timeStamp;
            assert(~obj.eventMap.isKey(time));
            obj.eventMap(time) = event;
            obj.heap.InsertKey(time);
        end
        
        %Constructor
        function obj = eventList(maxLength)
            obj.heap = MinHeap(maxLength);
            obj.eventMap = containers.Map('KeyType','double','ValueType','any');
        end
    end
    
end

