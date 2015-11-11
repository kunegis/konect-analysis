%
% Average between subject, object and global mean. 
%
% PARAMETERS
%	T	(r*3) Subject ID, object ID, rating 
%	m,n	subject count, object count
%
% RESULT
%	U,V	(m*1,n*1) Vectors such that U 1 + 1 V' is an approximation 
%

function [U,V] = means_euv(T, m, n)

A = konect_spconvert(T, m, n);

A_mask = (A ~= 0); 

e = .1 * mean(T(:,3))
U = .4 * (sum(A,2) ./ sum(A_mask, 2)) ;
V = .4 * (sum(A,1) ./ sum(A_mask, 1))';

U(U ~= U) = 0;
V(V ~= V) = 0;
U = U + e;
V = V + e; 
 
assert(sum(U ~= U) + sum(V ~= V) == 0); 

