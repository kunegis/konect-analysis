
function ret = rmse_latent(a1, a2, a3, U, X, V)

if ~size(v)
    v= u; 
end

sum = 0;

for i = 1 : size(a1,1)

    pred = U(a1(i),:) * X * V(a2(i),:)';
  
    sum = sum + (abs(pred - a3(i)))^2; 

end

ret = sqrt(sum / size(a1,1));

if isnan(ret) | isinf(ret), error('***'); end
