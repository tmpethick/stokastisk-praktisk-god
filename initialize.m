function [eventList, serverList] = initialize(n, servers, events, dtDist, mu_a, erlang_m)
%% Creating max-size event list
    eventList = cell(n*events,1);
    
%% Preparing first event
    customer.event = 'Arrival';
    customer.dt = arrivalTime(dtDist, mu_a, erlang_m);
    customer.t = customer.dt;
    1+1
    eventList{1} = customer;
    
%% Preparing servers availability
    serverList = zeros(servers,1);  % 0 = available, 1 = serving
end

