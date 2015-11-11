%
% Compute preferential attachment prediction.
%
% PARAMETERS
%	a		Adjacency/biadjacency matrix
%	at		(e*2) Vertex pairs for which to compute predictions
%	format
%	weights
%
% RESULT
%	predictions	Struct by submethod name of (e*1) Predictions
%

function [predictions] = prediction_local_compute_pref(a, at, format, weights)

consts = konect_consts(); 

if ~islogical(a)
  a = abs(a); 
end

su = sum(a, 2); 
sv = sum(a, 1)'; 

if format == consts.SYM
  su = su + sv;
  sv = su; 
end

predictions.main = su(at(:,1)) .* sv(at(:,2)); 
