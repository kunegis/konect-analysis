% 
% Save the full dataset (not split) in a MAT file.  If timestamps are
% present, the data is sorted. 
%
% PARAMETERS 
%	$NETWORK
%	$INPUT		Input filename (out.*)
%	$OUTPUT		Output filename (*.mat)
%
% INPUT 
%	$INPUT
% 
% OUTPUT 
%	$OUTPUT
%		T	The data in triple/quadruple format as found in the out.* file 
%

T = load(getenv('INPUT')); 

if size(T,2) >= 4
    [x,i] = sort(T(:,4));
    T = T(i, 1:3); 
end

save(getenv('OUTPUT'), '-v7.3', 'T'); 
