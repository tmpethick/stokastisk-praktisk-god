%% Using servicetime = exponential, betweentime = exponential

n = 10000;
events = 4;
servers = 10;
D.aDist = 'Exponential';
D.sDist = 'Exponential';
P.mu_a = 1; %mean time between customers
P.mu_s = 8; %mean service time
P.erlang = 3;
P.pareto = [1, 2.05];
P.constant = 1;

blocked = zeros(10,1);

maxT = 60*14;
count = 0;
for i=1:1
    lists = initialize(n, servers, D, P);
    nextEvent = lists.events.next();
    
    while (nextEvent.timeStamp < maxT)
        
        switch nextEvent.type
            case 'Arrive'
                lists = arrive(lists, D, P, nextEvent.timeStamp);
            case 'Departure'
                lists = depart(lists, nextEvent, D, P, nextEvent.timeStamp);
        end
    
        count = count + 1;
        nextEvent = lists.events.next();
    end
        
    disp(i)
end


intervals = confInt(blocked,0.05);
