classdef serverList < handle
%% Properties
    properties
        status
        type
        timeOccupied
    end

%% Methods
    methods

        function obj = occupyServer(obj, serverIdx, serviceTime)
            obj.status(serverIdx) = ServerStatus.Occupied;
            obj.timeOccupied(serverIdx) = serviceTime; %obj.timeOccupied(serverIdx) +
        end
        
        function obj = freeServer(obj, serverIdx)
            obj.status(serverIdx) = ServerStatus.Free;
        end

        function serverIdx = getFreeServer(obj)
            serverIdxs = find(obj.status== ServerStatus.Free);
            % Choose one server randomly from the list of all free servers
            serverIdx = serverIdxs(randi(length(serverIdxs)));
        end

        function has = hasFreeServer(obj)
             has = sum(obj.status) < length(obj.status);
        end

        % Constructor
        function obj = serverList(numServers)
            obj.status    = zeros(numServers,1);
            obj.type      = zeros(numServers,1);
            obj.timeOccupied = zeros(numServers,1);
        end
    end
    
end

