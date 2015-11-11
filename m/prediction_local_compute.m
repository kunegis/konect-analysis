% 
% Compute local prediction.
%
% PARAMETERS
%	method		Prediction method
%	a		Adjacency/biadjacency matrix
%	at		(e*2) Each row is a vertex pair (i,j) for which to compute a prediction
%	format
%	weights
%
% RESULT
%	predictions{submethod}		(e*1) Prediction scores 
% 

function [predictions] = prediction_local_compute(method, a, at, format, weights)

fh = str2func(sprintf('prediction_local_compute_%s', method)); 

predictions = fh(a, at, format, weights); 
