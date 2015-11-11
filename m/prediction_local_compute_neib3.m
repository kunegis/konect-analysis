%
% Compute neighborhood predictions, based on paths of length 3. 
%
% RESULT 
%	predictions	Struct by submethod name of (e*1)-vectors
%			containing the predictions
%
% PARAMETERS 
%	A		Adjacency/biadjacency matrix
%	T		(e*2) Vertex pairs for which to compute predictions
%	format		Format of network
%	weights		Weights of network 
%

function [predictions] = prediction_local_compute_neib3(A, T, format, weights)

consts = konect_consts(); 

[negative] = konect_data_weights(); 

predictions = struct(); 

submethods = { 'path3' }; 

N = length(submethods);

for i = 1 : N
    submethod = submethods{i}; 
    predictions.(submethod) = konect_predict_neib3(submethod, A, T, format); 
end
