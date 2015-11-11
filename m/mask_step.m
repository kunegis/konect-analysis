%
% One iteration step in mask approximation. 
%
% It must hold:  a = a .* w;  (i.e. a must be zero where w is zero.)
%
% PARAMETERS 
%	u	(m*1) The previous eigenvector
%	a	(m*n) Adjacency matrix
%	w	(m*1) The weight (or mask) matrix
%
% RESULT 
%	v	(n*1)
%

function v = mask_step(u, a, w)

if size(u,2) ~= 1
    error 'Invalid'
end

n = size(a,2); 

v = zeros(n,1);

fprintf(1, '  mask step /%d\n', n); 

t = konect_timer(n); 

for j = 1:n

    t = konect_timer_tick(t, j); 

    if mod(j,5000) == 0, fprintf(1, '    %d\n', j); end; 

    v(j,1) = pinv(u' * (u .* w(:,j))) * (u' * a(:,j));

end

konect_timer_end(t); 
