%
% This is the additive normalization used.  This function also knows
% which type of networks need normalization or not.   
%

function [U V] = means_best(T, m, n, weights)

%%consts = konect_consts(); 
[negative interval_scale] = konect_data_weights(); 

if interval_scale(weights)
    [U V] = means_euv(T, m, n);
else
    U = []; 
    V = []; 
end
