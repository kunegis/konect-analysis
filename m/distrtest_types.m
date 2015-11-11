
%
% Return the types that can be passed to distrtest_plot(). 
%
% RESULTS 
%	types	Cell array of all type names
%

function types = distrtest_types()

types = {'normal', 'lognormal', 'logistic', 'loglogistic', 'cauchy', 'logcauchy', ...
         'gumbel', 'weibull', 'hsd', 'loghsd', 'exp', 'pareto', ...
         'gamma', 'beta', 'halfnormal', 'gengamma', 'poisson'}; 

