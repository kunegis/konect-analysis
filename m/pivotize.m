%
% The norm used for normalizing central matrices. 
%
% PARAMETERS 
%	data_decomposition
%	x			Central matrix
%
% RESULT 
%	pivot 			The pivot value
%

function [pivot] = pivotize(data_decomposition, x)

pivot = 1; 

if ~data_decomposition.n

  if data_decomposition.l
    a = diag(x); 
    a_nonzero = a(a ~= 0); 
    if length(a_nonzero)
      pivot = min(abs(a_nonzero)); 
    end
  else
    pivot = norm(x); 
  end
end

if pivot <= 0, error('***'); end;
