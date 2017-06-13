function [eventList, serverList] = depart(e, eventList, serverList)
%% Freeing up the server
    serverList(eventList{e}.server,1) = 0;
end

