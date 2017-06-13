%% Using servicetime = exponential, betweentime = exponential

n = 10000;
events = 2;
servers = 10;
dtDist = 'Exponential';
stDist = 'Pareto';
mu_s = 8; %mean service time
mu_a = 1; %mean time between customers
erlang_m = 3;
pareto = [1, 2.05];
constant = 1;

blocked = zeros(10,1);


t = 1;
e = 1;
for i=1:10
    [eventList, serverList] = initialize(n, servers, events, dtDist, mu_a, erlang_m);

    while (t < n)
        switch eventList{e}.event
            case 'Arrival'
                [eventList, serverList] = arrive(e, eventList, serverList, dtDist, stDist, mu_a, erlang_m, mu_s, pareto, constant);
                t = t + 1;
            case 'Departure'
                [eventList, serverList] = depart(e, eventList, serverList);
        end
        
        e = e + 1;
    end
    i
    blocked(i) = 2*t-(e+servers);
    
    t = 1;
    e = 1;
end

blocked
intervals = confInt(blocked,0.05);

n=10;
A = (1/mu_a)*mu_s;
B = ((A^(n))/factorial(n))/(sum(A.^(1:n)./factorial(1:n)))