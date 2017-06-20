function [X] = PertDist(min,mode,max,Z,n,gamma)
% Purpose: Generate a pert distribution based on input.
% Author(s): Frederik Winkel Lehn
%% INPUT PARAMETERS
% min : Minimum-value of the distribution
% mode : Peak of the distribution
% max : Maximum-value of the distribution
% Z : A Z(n,1) vector of uniform random variables
% n : Number of generated numbers, the higher the number the higher the precision
% gamma : Parameter for weight on the mode, the higher the value the narrower the distribution
%% Ascertaining input arguments
generate_in_function = true;

if ~isempty(Z)
    generate_in_function = false;
    n=numel(Z);
end

if nargin < 6
    gamma = 4; %default Pert parameter
end

%defining known parameters and preallocating
alpha1 = 1+gamma*((mode-min)/(max-min));
alpha2 = 1+gamma*((max-mode)/(max-min));
X = zeros(n,1);

%% Generating the distribution if uniform values are given
if ~generate_in_function
    %Utilizing the parallel compatibility of matlab to reduce computational
    %time of the non-sequentially dependent loop
    for i=1:n
        alpha3 = betaincinv(Z(i,1),alpha1,alpha2);
        X(i) = (max-min)*alpha3+min;
    end
end
%% Generating the distribution if uniform values not given
if generate_in_function
    %Utilizing the parallel compatibility of matlab to reduce computational
    %time of the non-sequentially dependent loop
    for i=1:n
        U = rand;
        alpha3 = betaincinv(U,alpha1,alpha2);
        X(i) = (max-min)*alpha3+min;
    end
end
end

