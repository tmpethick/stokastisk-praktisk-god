classdef serverList < handle
%% Properties
    properties
        occupied
        type
    end
    
%% Methods
    methods
        function obj = setServer(obj, setType, server)
            switch setType
                case 'Occupy'
                    obj.occupied(server) = 1;
                case 'Free'
                    obj.occupied(server) = 0;
                otherwise
                    error('Server type incorrectly specified: Use bloody big letters')
            end
        end
        
        % Constructor
        function obj = serverList(n_s)
            obj.occupied    = zeros(n_s,1);
            obj.type        = cell(n_s,1);
        end
    end
    
end

