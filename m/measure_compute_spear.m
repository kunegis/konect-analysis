%
% Compute Spearman correlation link prediction measure.
%
% RESULT 
%	value	Correlation value
%
% PARAMETERS 
%	p	(e*1) Predictions
%	T	(e*3) To be predicted
%

function [value] = measure_compute_spear(p, T)

value = corr(p, T(:,3), 'type', 'Spearman'); 

