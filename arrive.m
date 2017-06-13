function [eventList, serverList] = arrive(e, eventList, serverList, dtDist, stDist, mu_a, erlang_m, mu_s, pareto, constant)
%% Initializing
    customer = eventList{e};
    
%% Raising departure event
    
    if (sum(serverList) < length(serverList))
        %Assigning server
        server = find(serverList == 0);
        server = server(1);
        serverList(server) = 1;
        customerD.server = server;
        
        %Assigning serving time
        st = serviceTime(stDist, mu_s, pareto, constant);
        customerD.st = st;
        
        %Assigning event
        customerD.event = 'Departure';
        
        
        %Finding index of last non-empty cell
        index = find(~cellfun('isempty',eventList),1,'last');
        
        %Adding to eventList
        t = customer.t + st;
        customerD.t = t;
        if (t < eventList{index}.t)
        
            for i=(e+1):index
                if (t < eventList{i}.t)
                    eventList(i+1:index+1) = eventList(i:index);
                    eventList{i} = customerD;
                    break;
                end
            end

        else
            eventList{index+1} = customerD;
        end
    end
    
    
%% Raising arrival event
    
    %Assigning arrival time
    dt = arrivalTime(dtDist, mu_a, erlang_m);
    customerA.dt = dt;
    customerA.event = 'Arrival';
    
    %Finding index of last non-empty cell
    index = find(~cellfun('isempty',eventList),1,'last');
    
    %Adding to eventList
    t = customer.t + dt;
    customerA.t = t;
    
    if (t < eventList{index}.t)
        
        for i=(e+1):index
            if (t < eventList{i}.t)
                eventList(i+1:index+1) = eventList(i:index);
                eventList{i} = customerA;
                break;
            end
        end
        
    else
        eventList{index+1} = customerA;
    end
    
end

