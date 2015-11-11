%
% Compute average precision. 
% 
% PARAMETERS 
%	p	(e*1) Predictions
%	T	(e*3) to be predicted
%
% RESULT 
%	value	Average precision
%

function [value] = measure_compute_ap(p, T)

value = konect_ap(p, T(:,3)); 
