function [n_seed] = guess_seed_function(lambda,fibre_len,net_type)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% Written by Hadi Wiputra
if strcmp(net_type, 'Delaunay')  
    c=0.0151682939;
    m=1.70632941;
elseif strcmp(net_type, 'Voronoi')    
    c=0.0550249544;
    m=2.343766408;
end

n_seed=(fibre_len.^2).*c.*(1./(-lambda-1)+1)+fibre_len.*m.*lambda;

end

