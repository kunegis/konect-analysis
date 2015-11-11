%
% Compute Kendall tau precision measure.
%
% RESULT 
%	value	Correlation value
%
% PARAMETERS 
%	p	(e*1) Predictions
%	T	(e*3) To be predicted
%

function [value] = measure_compute_kendall(p, T)

value = corr(p, T(:,3), 'type', 'Kendall'); 

