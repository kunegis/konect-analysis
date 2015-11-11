%
% Prepare target matrix for the diagonality test when in "base" mode,
% not self mode.  This is identical to konect_prepare_matrix(), only
% that for Laplacian decompositions this will return the underlying
% adjacency matrix.   
%

function [B] = prepare_matrix_target(decomposition, A, format)

if     strcmp(decomposition, 'lap'), 		decomposition = 'sym'; 		
elseif strcmp(decomposition, 'lapc'),		decomposition = 'sym'; 
elseif strcmp(decomposition, 'lapd'),		decomposition = 'svd'; 
elseif strcmp(decomposition, 'lapd-n'),		decomposition = 'svd-n'; 
elseif strcmp(decomposition, 'lapherm'),	decomposition = 'herm';
elseif strcmp(decomposition, 'lapskew'), 	decomposition = 'skewi';
elseif strcmp(decomposition, 'lapquantum'),	decomposition = 'quantum';
elseif strcmp(decomposition, 'lapq'),		decomposition = 'sym'; 
end


B = konect_matrix(decomposition, A, format);
