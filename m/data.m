% 
% Save the full dataset (not split) in a MAT file.  If timestamps are
% present, the data is sorted. 
%
% PARAMETERS 
%	$input		Input filename (out.*)
%	$output		Output filename (*.mat)
%
% INPUT FILES
%	$input
% 
% OUTPUT FILES 
%	$output		Matlab file
%		T	The data in triple/quadruple format as found in the out.* file 
%

T = load(getenv('input'));

if size(T,2) >= 4
    [x,i] = sort(T(:,4));
    T = T(i, 1:3); 
end

save(getenv('output'), '-v7.3', 'T'); 

