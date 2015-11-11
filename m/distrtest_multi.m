%
% Fit a distribution.  This version allows multiplicities for
% values, but does not draw a figure. 
%
% PARAMETERS 
%	type	String representing the type of distribution that is
%		tested against; see below for possible values
%	x	(k*1) The vector of values
%	c	(k*1) Counts
%
% RESULTS 
%	ret		A struct with the following fields:
%
%	n		Number of data points; equals sum(c)
%	k		Number of parameters of the model
%	param_names	(1*k) Cell array of the names of the parameters
%	params		(1*k) Parameters of the distribution
%	param_ci	(2*k) Matrix of confidence intervals; row 1
%			contains lower bounds; row 2 contains upper
%			bounds 
%	L_log		Log-likelihood
%	D		The Kolmogorov--Smirnov distance between the
%			given distribution and the postulated
%			distribution; NaN when not computed
%	p		The p-value, i.e., the probability that the
%			given distribution came from the postulated
%			distribution; NaN when not computed
%	A		Akaike information criterion
%	B		Bayes information criterion
%

function [ret] = distrtest_multi(type, x, c)

x = x(:);
c = c(:);

assert(length(x) == length(c));

type

% Quantile to show using horizontal lines
alphaprec = 0.05; 

line_width = 4; 

colors = distrtest_colors(); 

n = sum(c);

[x i] = sort(x);
c = c(i); 

r = cumsum(c) / n; 

% Other fields are filled by each distribution 
ret = struct();
ret.n = n; 

% The used expressions for y are the inverse cumulative distribution
% functions 
switch type

  case 'normal'
    % Normal distribution 
    mu = sum(c' * x) / n; 
    v = (((x - mu) .^ 2)' * c) / (n-1); 

    ret.k = 2;
    ret.params = [mu sqrt(v)]; 
    ret.param_names = { 'mu', 'sigma' };
    ret.L_log = -0.5 * n * log(2 * pi * v) - (n - 1) / 2;
    
  case 'lognormal'
    % Lognormal distribution 
    mu = sum(c' * log(x)) / n;
    v = (((log(x) - mu) .^ 2)' * c) / (n-1); 

    ret.k = 2;
    ret.params = [mu sqrt(v)]; 
    ret.param_names = { 'mu', 'sigma' }; 
    ret.L_log = - n * mu - 0.5 * n * log(2 * pi * v) - (n - 1) / 2;

otherwise

  xx = [];
  for i = 1 : length(x)
      xx = [xx ; repmat(x(i), c(i), 1) ];
  end

switch type
    
  case 'logistic'
    % Logistic distribution 

    ret.k = 2;
    [phat pci] = mle(xx, 'distribution', 'logistic');
    p_mu = phat(1);
    p_s = phat(2);
    ret.params = [ p_mu p_s ];
    ret.param_names = { 'mu', 's' };
    ret.param_ci = pci; 

    ret.D = ksdist(xx, @(X)(1 ./ (1 + exp(- (X - p_mu) ./ p_s))));
    x_norm = - (xx - p_mu) / p_s;
    ret.L_log = - n * log(p_s) + sum(x_norm) - 2 * sum(ln_spec(x_norm)); 

  case 'loglogistic'
    % Log-logistic distribution

    ret.k = 2;
    assert(sum(x < 0) == 0);
    i = (xx == 0);
    xx = xx(~i);
    [phat pci] = mle(xx, 'distribution', 'loglogistic');
    p_mu = phat(1); 
    p_s = phat(2); 
    % The parameters alpha and beta used on the Wikipedia page are
    % given by:
    %   mu = ln alpha
    %   s = 1 / beta
    
    ret.params = [ p_mu p_s ];
    ret.param_names = { 'mu', 's' };
    ret.param_ci = pci;
    
    p_alpha = exp(p_mu);
    p_beta = 1 / p_s;

    ret.D = ksdist(xx, @(X)(1 ./ (1 + (xx / p_alpha) .^ p_beta)));
    ret.L_log = n * log(p_beta) - n * p_beta * p_mu + (p_beta - 1) * sum(log(xx)) - 2 * sum(ln_spec((log(xx) - p_mu) / p_s));

  case 'cauchy'
    % Cauchy distribution 

  case 'logcauchy'
    % Log-Cauchy distribution

  case 'gumbel'
    % Gumbel distribution
    % Note:  The Weibull distribution can be characterized as the log-Gumbel distribution.

  case 'weibull'
    % Weibull distribution
    
    assert(sum(x < 0) == 0);
    i = (xx == 0);
    xx = xx(~i);

    [parmhat parmci] = wblfit(xx);
    p_lambda = parmhat(1);
    p_k = parmhat(2); 
    ret.params = [ p_lambda p_k ];
    ret.param_ci = parmci; 
    ret.param_names = {'lambda', 'k'};
    ret.k = 2;
    ret.D = ksdist(xx, @(X)(wblcdf(X, p_lambda, p_k)));
    ret.L_log = n * log(p_k) - n * p_k * log(p_lambda) + (p_k - 1) * sum(log(xx)) - sum((xx / p_lambda) .^ p_k); 

  case 'hsd'
    % Hyperbolic secant distribution 

  case 'loghsd'
    % Log-hyperbolic secant distribution"

  case 'exp'
    % Exponential distribution
    
    [h p] = lillietest(xx, 0.05, 'exp');
    ret.p = p;

    ret.k = 1;
    lambda = 1 / mean(xx);
    ret.params = [ lambda ];
    ret.param_names = { 'lambda' };
    ret.L_log = n * log(lambda) - lambda * sum(xx); 
    ret.D = ksdist(xx, @(X)(1 - exp(-lambda * X)));

  case 'pareto'
    % Pareto distribution

    % Note:  min(x) is not necessarily a good estimator ofthe
    % parameter x_min of the Pareto distribution.
    [h p] = lillietest(log(xx / min(xx)), 0.05, 'exp');
    ret.p = p;

  case 'gamma'
    % Gamma distribution
    assert(sum(x < 0) == 0);
    i = (xx == 0);
    xx = xx(~i);
    [phat pci] = gamfit(xx); 
    p_k = phat(1);     % = \alpha 
    p_theta = phat(2); % = 1 / \theta
    ret.params = [p_k p_theta]; 
    ret.param_names = { 'k', 'theta' }; 
    ret.param_ci = pci;

    ret.k = 2;
    ret.D = ksdist(xx, @(X)(gamcdf(X, p_k, p_theta)));
    ret.L_log = - n * p_k * log(p_theta) - n * gammaln(p_k) + (p_k - 1) * sum(log(xx)) - p_theta * sum(xx);

  case 'beta'
    % Beta distribution
    [phat pci] = betafit(xx);
    alpha = phat(1);
    beta = phat(2);
    ret.params = [alpha beta]; 
    ret.param_names = { 'alpha', 'beta' };
    ret.param_ci = pci;

    ret.k = 2;
    ret.D = ksdist(xx, @(X)(betacdf(X, alpha, beta)));
    ret.L_log = - n * betaln(alpha, beta) + (alpha - 1) * sum(log(xx)) + (beta - 1) * sum(log(1 - xx));

  case 'burr'
    % Not supported in our version of Matlab
    [phat pci] = mle(xx, 'distribution', 'Burr');
    p_alpha = phat(1);
    p_c = phat(2);
    p_k = phat(3);

    ret.k = 2;
    ret.params = [ p_alpha p_c p_k ];
    ret.param_names = { 'alpha', 'c', 'k' };
    ret.param_ci = pci;
    ret.D = ksdist(xx, @(X)(1 - (1 + (X / p_alpha) .^ p_c) .^ (- p_k)));
    x_ln_alpha = log(xx / p_alpha); 
    ret.L_log = n * log(p_k * p_c / p_alpha) + (p_c - 1) * sum(x_ln_alpha) - (p_k + 1) * sum(ln_spec(p_c * x_ln_alpha)); 

  case 'halfnormal'
    p_sigma = sqrt(sum(xx .^ 2) / n);

    ret.k = 1;
    ret.params = [ p_sigma ];
    ret.param_names = { 'sigma' };
    ret.D = ksdist(xx, @(X)(erf(X / (sqrt(2) * p_sigma))));
    ret.L_log = 0.5 * n * log((2 / pi) * (p_sigma .^ -2)) - sum(xx .^ 2) / (2 * p_sigma^2);

  case 'gengamma'
    % Generalized Gamma distribution 
    assert(sum(x < 0) == 0);
    i = (xx == 0);
    xx = xx(~i);
    phat = fitgengam(xx) % This function is from WAFO (version 25)
    if ~isnan(phat.params(1))
        p_alpha = phat.params(1); % Name in WAFO:  a;   Name in Wikipedia:  d/p
        p_beta  = phat.params(2); % Name in WAFO:  b;   Name in Wikipedia:  a
        p_gamma = phat.params(3); % Name in WAFO:  c;   Name in Wikipedia:  p
        ret.k = 3;
        ret.params = [ p_alpha p_beta p_gamma ];
        ret.param_names = { 'alpha', 'beta', 'gamma' };
        ret.L_log = phat.loglikemax;
        ret.p = phat.pvalue;
        ret.D = ksdist(xx, @(X)(cdfgengam(X, p_alpha, p_beta, p_gamma)));
    end

  case 'poisson'
    % The Poisson distribution
    % This is the only discrete distribution considered here 
    p_lambda = mean(xx);
    ret.k = 1;
    ret.params = [ p_lambda ];
    ret.param_names = { 'lambda' };
    ret.L_log = log(p_lambda) * sum(xx) - sum(gammaln(xx + 1)) - n * p_lambda;
    
  otherwise
    error(sprintf('*** Invalid distribution %s', type)); 
end
end

%
% Information criteria
%

if isfield(ret, 'L_log') 
    ret.A = 2 * ret.k - 2 * ret.L_log + 2 * ret.k * (ret.k + 1) / (n - ret.k - 1); 
    ret.B = ret.k * log(n) - 2 * ret.L_log; 
end

end

%
% Compute y = log(1 + exp(x)) in a way that's accurate for both very
% small and very large x. 
%
function y = ln_spec(x)

y = ((x < 0) .* (log(1 + exp(x)))) + ((x >= 0) .* (x + log(1 + exp(-x))));

end
