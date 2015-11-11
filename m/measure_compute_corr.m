%
% Compute Pearson correlation error measure.
%
% RESULT 
%	value	Correlation value
%
% PARAMETERS 
%	p	(e*1) Predictions
%	T	(e*3) To be predicted
%

function [value] = measure_compute_corr(p, T)

value = corr(p, T(:,3)); 

if ~isfinite(value)
    % An undefined Pearon correlation means constant predictions, so
    % the results is 0. 
    value = 0; 
end
