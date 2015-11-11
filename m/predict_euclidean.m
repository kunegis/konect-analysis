%
% Predict Euclidean predictions.  The result is the negative Euclidean
% distance in the matrix M with MM' = U abs(D) V'. 
%
% RESULT 
%	prediction	(e*1) Prediction values 
%
% PARAMETERS 
%	u		(m*r) Left eigenvectors
%	d		(r*r) Central matrix
%	v		(n*r) Rigth eigenvectors; may be []
%	at		(e*2) Pairs of vertices to predict for 
%

function [prediction] = predict_euclidean(U, D, V, T)

chunk_size = 10000; 

[UU DD] = eig(D);

D_sqrt = UU * sqrt(abs(DD)); 

U = U * D_sqrt;

if ~length(V)
  V = U;
else
  V = V * D_sqrt; 
end

[k from to] = konect_fromto(1, size(T,1), chunk_size);

prediction = []; 

for i = 1:k

  from_i = from(i); 
  to_i = to(i); 
  %  fprintf(1, '%d - %d\n', from_i, to_i); 

  T_i = T(from_i : to_i, :); 

  dif = U(T_i(:,1),:) - V(T_i(:,2),:); 

  prediction = [ prediction ; - sum(conj(dif) .* dif, 2) ]; 
end
