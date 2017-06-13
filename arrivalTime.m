function dt = arrivalTime(aDist, P)
%% Initializing
    %Simulating the arrival process
    switch aDist
        case 'Exponential'
            dt = exprnd(P.mu_a); 
            
        case 'Erlang'
            dt = sum(exprnd(P.mu_a/P.erlang,1,P.erlang),2);
            
        case 'HyperExponential'
            p = [0.8, 0.2];
            lambda = [0.8333, 5];
            B = binornd(1,p(1));
            H1 = exprnd(1/lambda(1));
            H2 = exprnd(1/lambda(2));
            dt = B.*H1+(1-B).*H2;
    end


end

