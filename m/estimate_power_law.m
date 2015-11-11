%
% Estimate a power law when only the largest values are known.   
%
% Don't use this for degrees.  For degrees, not all values are necessarily known and power_law_*() should be used. 
%
% PARAMETERS
%	values		Values. Nonpositive values are ignored. 
%
% RESULT
%	alpha		Negative slope, .a.k.a. the power law exponent 
%
function alpha = estimate_power_law(values)

values = values(values > 0); 

values = sort(values, 'descend'); 

log_values = log(values); 

p = polyfit((1:length(values))', log_values, 1); 

alpha = exp(-p(1)); 

