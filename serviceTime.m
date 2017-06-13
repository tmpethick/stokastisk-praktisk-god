% Marcus kommentar
function st = serviceTime(stDist, mu_s, pareto, constant)
%% Generating
    %Simulating the service time process
    switch stDist
        case 'Exponential'
            st = exprnd(mu_s);
            
        case 'Constant'
            st = constant;
            
        case 'Pareto'
            U = rand;
            st = pareto(1)*U^(-1/pareto(2));
    end

end

