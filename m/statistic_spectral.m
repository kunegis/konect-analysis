%
% Compute a spectral statistic.  A spectral statistic is one that
% depends on the rank-r spectrum (and not just on the first or second
% eigenvalues). 
%
% RESULT 
%	values		Column vector of values
%
% PARAMETERS 
%	D		(r*r) Eigenvalues or equivalent
%	statistic
%	n		Number of nodes
%

function values = statistic_spectral(statistic, D, n)

if strcmp(statistic, 'network_rank_abs')

    dd = abs(diag(D)); 
    values = sum(dd) / dd(1); 

elseif strcmp(statistic, 'network_rank_norm')

    values = sum(abs(diag(D))); 

elseif strcmp(statistic, 'network_rank_norm4')

    values = sum(abs(diag(D)) .^ 4); 

elseif strcmp(statistic, 'epower')

    values = estimate_power_law(abs(diag(D))); 

elseif strcmp(statistic, 'entropy') | strcmp(statistic, 'entropyn')

    values = konect_normalized_entropy(abs(diag(D))); 

elseif strcmp(statistic, 'aredis')

    epsilon = 1e-11; 
  
    dd = diag(D);
    dd(dd < epsilon) = 0; 
    dd = dd .^ -1;
    dd(isinf(dd)) = 0;
    values = [ sum(dd) ];   

    values = values * 2 / n; 

elseif strcmp(statistic, 'oddcycles')

    dd = diag(D);

    alpha = 1 / max(abs(dd)); 

    x = alpha * dd;

    oddcycles = sum(sinh(dd)) / sum(exp(dd)); 
    oddcycles_2 = sum(sinh(x)) / sum(exp(x)); 
    oddcycles_3 = sum(x(2:end) ./ (1 - x(2:end) .^ 2)) / sum((-x(2:end) + 1) .^ -1); 

    values = [ oddcycles; oddcycles_2; oddcycles_3 ]; 

else
    error(sprintf('*** Invalid spectral statistic %s', statistic)); 
end
