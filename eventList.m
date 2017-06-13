classdef eventList < handle
%% Properties    
    properties
        list    %list
        e       %index
    end
    
%% Methods
    methods
        function event = next(obj)
            event = obj.list{obj.e};
            obj.e = obj.e + 1;
        end
        
        
        function obj = addToEventList(obj, event)
            %Finding index of last non-empty cell
            index = find(~cellfun('isempty',obj.list),1,'last');

            % Adding to event list
            t = event.timeStamp;
            if (t < obj.list{index}.timeStamp)

                for i=(obj.e+1):index
                    if (t < obj.list{i}.timeStamp)
                        obj.list(i+1:index+1) = obj.list(i:index); %heavy computational part
                        obj.list{i} = event;
                        break;
                    end
                end

            else
                obj.list{index+1} = event;
            end
        end
        
        %Constructor
        function obj = eventList(maxLength)
            obj.list = cell(maxLength,1);
            obj.e = 1;
        end
    end
    
end

