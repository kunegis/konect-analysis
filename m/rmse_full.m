
function ret = rmse_full(A, U, X, V)

if ~size(V)
    V= U; 
end

di = A - U * X * V'; 

ret = sum(sum(conj(di) .* di)) / prod(size(A))

if isnan(ret) | isinf(ret), error('***'); end
