%
% Convert a spectrum to real values that can be visualized.
%
% In all cases we take simply the real part, except for skew
% decompositions, where we take the imaginary part.  (A more complex
% example would be the complex logarithm for orthogonal matrices, whose
% eigenvalues are unitary.)
%
% RESULT 
%	ret		Real values 
%
% PARAMETERS 
%	spectrum	Complex spectrum to visualize
%	decomposition	Decomposition
%

function ret = spectrum_visualize(spectrum, decomposition)

data_decomposition = konect_data_decomposition(decomposition); 

if data_decomposition.i
%if strcmp(decomposition, 'skew') | strcmp(decomposition

  ret = imag(spectrum); 

else

  ret = real(spectrum); 

end

