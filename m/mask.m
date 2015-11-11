%
% Mask approximation of rank 1.  We use the row-column (RC) algorithm
% from [1] and use SVD to initialize the eigenvectors. 
%
% [1] Estimation of Rank Deficient Matrices from Partial Observations:
%     Two-Step Iterative Algorithms, Rui F. C. Guerreiro and Pedro M. Q.
%     Aguiar.  
%
% PARAMETERS 
%	a	(m*n)	Matrix to approximate
%	w	(m*n)	Weight (or mask) matrix, usually (a~=0)
%
% RESULT 
%	u,v	(m*1,n*1)	u*v' is the rank-1 approximation
%
% TODO 
%	extend to rank > 1. 
% 	convergence criterion. 
%

function [u,v] = mask(a, w)

[m,n] = size(a); 

opts.disp = 2; 
[u,d,v] = svds(a, 1, 'L', opts); 

u = u .* sqrt(d); 

for j = 1:16
    
    u_old = u;

    v = mask_step(u, a, w);
    u = mask_step(v, a', w'); 

    if mod(j,5) == 0
        square_sum = 0;
        if m < n
            for i = 1:m
                square_sum = square_sum + sum(((u(i,:) * v' - a(i,:)) .* w(i,:)).^2);
            end
        else
            for i = 1:n
                square_sum = square_sum + sum(((v(i,:) * u' - a(:, i)') .* w(:, i)').^2);
            end
        end
        norm_uv = sqrt(square_sum); 

        fprintf(1, '  [%d] normdiff(u) = %g  normdiff(uvT) = %g\n', ...
                j, ...
                norm(u - u_old), ...
                norm_uv); 
    end
end
