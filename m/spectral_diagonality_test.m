%
% Compute the spectral diagonality test matrix.
%
% This is the matrix \Delta in Jérôme's PhD thesis.
%
% PARAMETERS 
%	decomposition			The decomposition that is used 
%	decomposition_source		The actual decomposition of the source matrix
%		.U, .D, .V (optional)
%	A_target			The target matrix
%	format				Format of the network
%	enable_self			Mode (optional)
%		0			(default) Use base matrix
%		1			Use the same matrix 
%

function [Delta] = spectral_diagonality_test(decomposition, decomposition_source, ...
                                             A_target, format, enable_self)

if ~exist('enable_self', 'var')
    enable_self = 0; 
end

enable_self 

data_decomposition = konect_data_decomposition(decomposition);

size_A_target = size(A_target)
if enable_self
    A_target = konect_matrix(decomposition, A_target, format); 
else % base
    A_target = prepare_matrix_target(decomposition, A_target, format); 
end
size_A_target = size(A_target)


U = decomposition_source.U;
V = decomposition_source.V; 

size_U = size(U)
size_V = size(V) 

if length(V) > 0 && size(U,1)+size(V,1) == size(A_target,1) && size(A_target,1) == size(A_target,2);
    U = [U ; V]; 
    V = []; 
end

if length(V)

    if data_decomposition.o
        u_i = U'; 
        v_i = V'; 
    else
        u_i = konect_xpinv(U);
        v_i = konect_xpinv(V);
    end

    if strcmp(decomposition, 'skew')
        Delta = u_i * A_target * v_i' - v_i * A_target * u_i'; 
    else
        size_u_i = size(u_i)
        size_v_i = size(v_i)
        size_A_target = size(A_target)
            
        Delta = u_i * A_target * v_i';
    end

else

    if data_decomposition.o
        u_i = U'; 
    else
        u_i = konect_xpinv(U);
    end
    
    Delta = u_i * A_target * u_i'; 

end

