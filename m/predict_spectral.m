%
% Compute spectral predictions.  Predictions correspond to elements of
% the matrix UDV', or UDV' - VDU' for the skew decomposition. 
%
% RESULT 
%	prediction	(e*1) Prediction values 
%
% PARAMETERS 
%	U		(m*r) Left eigenvectors
%	D		(r*r) Central matrix 
%	V		(n*r) Right eigenvectors, may be [] in which case U is used in its place 
%	T		(e*2) Pairs of vertices for which to compute link prediction scores 
% 	decomposition
%	

function [prediction prediction_complex] = predict_spectral(U, D, V, T, decomposition)

chunk_size = 20000; 

% The predictions are computed as A * B 
if strcmp(decomposition, 'skew')

    A = [ U * D, -V * D ];
    B = [ V, U ];

else

    A = U * D; 

    if length(V)
        B = V; 
    else
        B = U;
    end
end

clear U D V;

[k from to] = konect_fromto(1, size(T,1), chunk_size);

prediction = []; 

t = konect_timer(k); 

for i = 1:k

    t = konect_timer_tick(t, i); 

    from_i = from(i); 
    to_i = to(i); 

    T_i = T(from_i : to_i, :); 

    prediction_i = sum(A(T_i(:,1), :) .* B(T_i(:,2), :), 2); 
	  
    prediction = [ prediction ; prediction_i ]; 

end

konect_timer_end(t); 

data_decomposition = konect_data_decomposition(decomposition); 

if ~isreal(prediction) | data_decomposition.imag
    prediction_complex = imag(prediction); 
    prediction = real(prediction); 
else
    prediction_complex = [];
end
