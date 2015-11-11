%
% Compute zero prediction, i.e. always predict zero. 
%
% PARAMETERS
%	a		Adjacency/biadjacency matrix
%	at		(e*2) Vertex pairs for which to compute predictions
%	format
%	weights
%
% RESULT
%	predictions	Struct by subname of (e*1) Predictions
%

function [predictions] = prediction_local_compute_zero(a, at, format, weights)

predictions.main = zeros(size(at,1), 1); 
