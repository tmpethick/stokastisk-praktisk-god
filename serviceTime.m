function st = serviceTime(sDist, P)
%% Generating
    %Simulating the service time process
    switch sDist
        case 'Exponential'
            st = exprnd(P.mu_s);
            
        case 'Constant'
            st = P.constant;
            
        case 'Pareto'
            U = rand;
            st = P.pareto(1)*U^(-1/P.pareto(2));
    end

end

