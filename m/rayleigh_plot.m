%
% Plot the Rayleigh quotient distribution.
%
% PARAMETERS 
% 	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/rayleigh.$DECOMPOSITION.$NETWORK.mat
%
% OUTPUT 
%	plot/rayleigh.$DECOMPOSITION.{a}.$NETWORK.eps
%

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 

data = load(sprintf('dat/rayleigh.%s.%s.mat', decomposition, network));

values = data.values;
k = length(values);

%
% (b) - Normal function
%

plot(values, erfinv(((1:k) / k) * 2 - 1), 'r-'); 

xlabel('\lambda');
ylabel('erfinv(P(x \leq \lambda) * 2 - 1)');

konect_print(sprintf('plot/rayleigh.%s.b.%s.eps', decomposition, network)); 

%
% (a) - Cumulated distribution
%

plot(values, (1:k) / k, '-');

xlabel('\lambda');
ylabel('P(x \leq \lambda)');

konect_print(sprintf('plot/rayleigh.%s.a.%s.eps', decomposition, network)); 

       

