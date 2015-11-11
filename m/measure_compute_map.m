%
% Compute mean average precision. 
%
% PARAMETERS
%	p	(e*1) Predictions
%	T	(e*3) To be predicted
%
% RESULT
%	value	MAP value
%

function [value] = measure_compute_map(p, T)

value = konect_map(p, T); 
 

