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
            indexes = find(obj.status== ServerStatus.Free);
            index = indexes(1);
        end

        function has = hasFreeServer(obj)
             has = sum(obj.status) < length(obj.status);
        end

        % Constructor
        function obj = serverList(n_s)
            obj.status    = zeros(n_s,1);
            obj.type      = zeros(n_s,1);
        end
    end
    
end

