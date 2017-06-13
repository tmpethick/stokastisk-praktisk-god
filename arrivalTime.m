function dt = arrivalTime(dtDist, mu_a, erlang_m)
%% Initializing
    %Simulating the arrival process
    switch dtDist
        case 'Exponential'
            dt = exprnd(mu_a); 
            
        case 'Erlang'
            dt = sum(exprnd(mu_a/erlang_m,1,erlang_m),2);
            
        case 'HyperExponential'
            p = [0.8, 0.2];
            lambda = [0.8333, 5];
            B = binornd(1,p(1));
            H1 = exprnd(1/lambda(1));
            H2 = exprnd(1/lambda(2));
            dt = B.*H1+(1-B).*H2;
    end


end

