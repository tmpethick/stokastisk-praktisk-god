classdef serverList < handle
%% Properties
    properties
        status
        type
    end

%% Methods
    methods

        function obj = occupyServer(obj, serverIdx)
            obj.status(serverIdx) = ServerStatus.Occupied;
        end
        
        function obj = freeServer(obj, serverIdx)
            obj.status(serverIdx) = ServerStatus.Free;
        end

        function index = getFreeServer(obj)
            indexes = find(obj.status == ServerStatus.Free);
            index = indexes(1);
        end

        function has = hasFreeServer(obj)
            has = sum(obj.status) < length(obj.status);
        end

        % Constructor
        function obj = serverList(n_s,nSelfService)
            obj.status    = zeros(n_s,1);
            obj.type        = cell(n_s,1);
            obj.type{1:nSelfService} = 'Self-Service';
            obj.type{nSelfService+1:end} = 'Normal Service';
        end
    end
    
end

