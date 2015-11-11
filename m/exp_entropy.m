%
% The exp-entropy, i.e. the entropy of a vector given by considering the
% exponential of its entries as probabilities.  Used with eigenvalues in
% [671]. 
%
% RESULT 
%	entropy	Entropy 
%
% PARAMETERS 
%	values 	Vector of values
%

function entropy = exp_entropy(values)

values = values - max(values);

lnsum = log(sum(exp(values)));

values = values - lnsum;

entropy = - sum(exp(values) .* values);

