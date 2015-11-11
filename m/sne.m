%
% Spectral network evolution.
%
% Both decompositions need not be of the same size. 
%
% V and source_V are [] for symmetric decompositions. 
%
% RESULT 
%	dd_new		Predicted new eigenvalues
%
% PARAMETERS 
%	source_U		Decomposition of source set 
%	source_dd
%	source_V
%	U,dd,V			Decomposition of training set
%	func			
%		(optional) Function mapping the scalar product of eigenvectors to a
%		weight; defaults to f(x) = x. 
%

function [dd_new] = sne(source_U, source_dd, source_V, ...
                        U, dd, V, func)

if ~exist('func', 'var')
    func = @(x)(x); 
end

k = size(U,2); 
k_old = size(source_U,2); 

asymmetric = size(V); 

dd_old = dd; 

for i = 1:k

    d_sum = 0; 
    weight_sum = 0;

    for j = 1:k_old
        weight_u = source_U(:,j)' * U(:,i); 

        if asymmetric
            weight_v = source_V(:,j)' * V(:,i);  
        end

        if asymmetric
            weight = func(weight_u * weight_v); 
        else
            weight = func(weight_u ^2); 
        end

        weight_sum = weight_sum + weight;
        d_sum = d_sum + weight * source_dd(j); 
    end

    if weight_sum == 0
        weight_sum = 1; 
    end

    dd_old(i) = d_sum / weight_sum;     

end

dd_new = dd - dd_old; 
