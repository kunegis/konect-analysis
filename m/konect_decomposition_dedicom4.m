%
% Moved to here from the Matlab toolbox because it doesn't work.  The
% iterations do not converge. 
%
% Iterative solution to DEDICOM from [1]:
%
%	A = U D U'
%
% [1] Models for Analysis of Asymmetrical Relationships Among
%     N Objects or Stimuli, Richard A. Harshman, Proc. First Meeting of
%     the Psychometric Society and The Society for Methematical
%     Phychology, 1978. 
%
% RESULT 
%	U	(n*r) Factor matrix with orthonormal columns
%	D	(r*r) Central asymmetric matrix
%
% PARAMETERS 
%	A	(n*n) Square asymmetric adjacency matrix
%	r	Rank
%	opts	Options for svds()
%

function [U D] = konect_decomposition_dedicom4(A, r, opts)

[uu D vv] = svds(double(A), r, 'L', opts); 

epsilon = 1e-7; 
  
for i = 1:100000
    U = 0.5 * (uu + vv); 
    d_old = D; 

    % Decompose U
    [u_u u_d u_v] = svd(U, 'econ'); 
    u_d_i = konect_xinv(u_d); 

    % This computes D = U \ A / U';
    D = u_v * (u_d_i * (u_u' * A * u_u) * u_d_i' * u_v');
    
    % Reorder here because otherwise the convergence test does not work.
    [U D] = konect_order_dedicom(U, D); 

    if rem(i,20) == 0
        dif = norm(D - d_old, 'fro')^2 / prod(size(D)); 
        fprintf(1, 'iteration %d dif= %g\n', i, dif); 
        if dif < epsilon, break; end; 
    end

    % Compute uu = A / U' / D;
    uu = A * u_u * (u_d_i' * u_v' * pinv(D)); 

    % Compute vv = A' / U' / D';
    vv = A' * uu * (u_d_i' * u_v' * pinv(D'));

    % Orthonormalize
    [qu ru] = qr(uu, 0);
    [qv rv] = qr(vv, 0);
    D = ru * D * rv';
    uu = qu;
    vv = qv; 
end

