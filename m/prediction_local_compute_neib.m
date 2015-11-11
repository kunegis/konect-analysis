%
% Compute neighborhood predictions. 
%
% RESULT 
%	predictions	Struct by submethod name of (e*1) Predictions
%
% PARAMETERS 
%	A		Adjacency/biadjacency matrix
%	T		(e*2) Vertex pairs for which to compute predictions
%	format
%	weights
%

function [predictions] = prediction_local_compute_neib(A, T, format, weights)

consts = konect_consts(); 

[negative] = konect_data_weights(); 

predictions = struct(); 

if format == consts.BIP
    return; 
end

submethods = { 'common', 'adad', 'ra', 'jaccard', 'cosine', 'sorensen', 'hpi', 'hdi', 'lhni' }; 
submethods_negative = { 'abscommon', 'absadad', 'absjaccard', 'abscosine' }; 

N = length(submethods);
if negative(weights)
    N = N + length(submethods_negative); 
end
if format == consts.ASYM
    N = N + 3 * length(submethods); 
end

t = konect_timer(N); 

I = 1; 

for i = 1 : length(submethods)
    t = konect_timer_tick(t, I); I = I + 1; 
    submethod = submethods{i}; 
    predictions.(submethod) = konect_predict_neib(submethod, A, T, format, 'sym'); 
end

if negative(weights)
    for i = 1 : length(submethods_negative)
        t = konect_timer_tick(t, I); I = I + 1; 
        submethod = submethods_negative{i}; 
        predictions.(submethod) = konect_predict_neib(submethod, A, T, format, 'sym'); 
    end
end

if format == consts.ASYM
    for i = 1 : length(submethods)
        t = konect_timer_tick(t, I); I = I + 1; 
        submethod = submethods{i}; 
        predictions.([submethod 'asym']) = konect_predict_neib(submethod, A, T, format, 'asym'); 
        predictions.([submethod 'out' ]) = konect_predict_neib(submethod, A, T, format, 'out' ); 
        predictions.([submethod 'in'  ]) = konect_predict_neib(submethod, A, T, format, 'in'  ); 
    end
end

konect_timer_end(t); 
