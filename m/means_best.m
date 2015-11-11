%
% This is the additive normalization used.  This function also knows which type of networks need normalization or not. 
%

function [U V] = means_best(T, m, n, weights)

consts = konect_consts(); 

if weights == consts.SIGNED | weights == consts.WEIGHTED

    [U V] = means_euv(T, m, n);

else

    U = []; 
    V = []; 

end
