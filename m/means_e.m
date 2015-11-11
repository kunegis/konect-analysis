function [U,V] = means_e(T_training, m, n)

e = .5 * mean(at_training(:,3)); 

U = e * ones(m,1); 
V = e * ones(n,1); 
