classdef serverList < handle
%% Properties
    properties
        occupied
        type
    end
    
%% Methods
    methods
        function obj = setServer(obj, setAvailability, server)
            switch setAvailability
                case 'Occupy'
                    obj.occupied(server) = 1;
                case 'Free'
                    obj.occupied(server) = 0;
                otherwise
                    error('Server availability incorrectly specified: Use bloody big letters')
            end
        end
        
        % Constructor
        function obj = serverList(n_s,nSelfService)
            obj.occupied    = zeros(n_s,1);
            obj.type        = cell(n_s,1);
            obj.type{1:nSelfService} = 'Self-Service';
            obj.type{nSelfService+1:end} = 'Normal Service';
        end
    end
    
end

