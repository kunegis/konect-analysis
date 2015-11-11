%
% The means by linear regression. 
%

function [U,V] = means_regr(T, m, n)

r = size(T, 1); 
s = round(r * .8); 
val = (1+s) : r; 

A_training = konect_spconvert(T(1:s, :), m, n); 
A_training_mask = (A_training ~= 0); 

A_testtraining = konect_spconvert(T, m, n); 
A_testtraining_mask = (A_testtraining ~= 0); 

meane = mean(T(1:s,3))
meanu = sum(A_training, 2) ./ sum(A_training_mask,2); 
meanv = sum(A_training, 1)' ./ sum(A_training_mask,1)'; 

meanu(meanu ~= meanu) = 0; 
meanv(meanv ~= meanv) = 0; 

pred_e = meane * ones(r-s,1); 
pred_u = meanu(T(val,1)); 
pred_v = meanv(T(val,2)); 

targ = T(val,3); 

w_regr = [pred_e pred_u pred_v] \ targ

meane = mean(T(:,3)); 
meanu = sum(A_testtraining, 2)  ./ sum(A_testtraining_mask,2); 
meanv = sum(A_testtraining, 1)' ./ sum(A_testtraining_mask,1)'; 

meanu(meanu ~= meanu) = 0; 
meanv(meanv ~= meanv) = 0; 

U = .5 * w_regr(1) * meane + w_regr(2) * meanu;
V = .5 * w_regr(1) * meane + w_regr(3) * meanv;
