%
% Compute area under the curve. 
% 
% PARAMETERS
%	p	(e*1) Predictions
%	at	(e*3) To be predicted 
%
% RESULT
%	value	Area under the curve 
%

function [value] = measure_compute_auc(p, at)

value = konect_auc(p, at(:,3)); 
