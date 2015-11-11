%
% Compute mean area under the curve. 
%
% PARAMETERS
%	p	(e*1) Predictions
%	at	(e*3) To be predicted
%
% RESULT
%	value	MAUC value
%

function [value] = measure_compute_mauc(p, at)

value = konect_mauc(p, at); 
 

