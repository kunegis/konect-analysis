%
% Compute the Rank-1 mask approximation (only when there is
% no "zero").   See mask.m
%
% PARAMETERS
%	a		Adjacency/biadjacency matrix
%	at		(e*2) Vertex pairs for which to compute predictions
%	format
%	weights
%
% RESULT
%	predictions{submethod}	Struct by submethod name of (e*1) Predictions
%		'main'		(only SIGNED and WEIGHTED) rank-1 mask
%				approximation 
%

function [predictions] = prediction_local_compute_mask(a, at, format, weights)

consts = konect_consts();

predictions = struct(); 

if weights == consts.SIGNED | weights == consts.WEIGHTED

  [u v] = mask(a, a ~= 0);
  predictions.main = u(at(:,1)) .* v(at(:,2)); 
end

