%
% Compute the reduced rank in function of decomposition type.
%

function r = get_rank_type(network, decomposition)

[r_svd, r_lap] = get_rank(network);

if     strcmp(decomposition, 'svd' ),   r = r_svd; 
elseif strcmp(decomposition, 'sym' ),   r = r_svd;
elseif strcmp(decomposition, 'diag' ),  r = r_svd;

elseif strcmp(decomposition, 'lapb'),   r = r_lap; 
elseif strcmp(decomposition, 'laps'),   r = r_lap; 
elseif strcmp(decomposition, 'svd-n'),  r = r_lap; 
elseif strcmp(decomposition, 'sym-n'),  r = r_lap; 

elseif strcmp(decomposition, 'takane'),		r = max(5, floor(r_lap / 3)); 
elseif strcmp(decomposition, 'lapd'), 		r = max(5, floor(r_lap / 3)); 
elseif strcmp(decomposition, 'dedicom3'), 	r = max(5, floor(r_lap / 3)); 

else		               r = r_lap;

end

