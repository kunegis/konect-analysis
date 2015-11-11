%
% Compute the Kolmogorov--Smirnov distance between a given sample and
% a given continuous distribution.
%
% PARAMETERS 
%	x	(n*1) The sample
%	F	@(x)(P(<=x)) The cumulative distribution function;
%		this function must take as input a vector of values,
%		and return a vector of the same size containing, for
%		each x, the probability that a variable is smaller or
%		equal to x, i.e., the cumulative distribution
%		function 
%
% RESULTS 
%	D	The Kolmogorov--Smirnov distance
%

function D = ksdist(x, F)

n = length(x);

x = sort(x);

f = F(x);

D = max(max(abs((0:(n-1))'/n - f)), max(abs((1:n)'/n - f))); 
%D = max(abs(((1:n)'-0.5)/n - f));
