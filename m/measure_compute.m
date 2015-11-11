%
% Compute a link prediction measure.
%
% PARAMETERS
%	measure Name of measure 
%	p	(e*1) Predictions
%	T	(e*3) To be predicted 
%
% RESULT
%	value	Link prediction measure ; higher is better 
%
function [value] = measure_compute(measure, p, T)

fh = str2func(sprintf('measure_compute_%s', measure)); 

value = fh(p, T); 