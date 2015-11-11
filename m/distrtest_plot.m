%
% Draw a plot that tests whether a given vector of numbers follows a
% specific distribution, i.e., a Q-Q plot between the given data and
% a known distribution. 
%
% PARAMETERS 
%	type	String representing the type of distribution that is
%		tested against; see below for possible values
%	x	The vector of values
%	no_plot	(0/1) [default = 0] Omit plotting
%
% RESULTS 
%	ret		A struct with the following fields:
%
%	n		Number of data points; equals length(x) 
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
% TODO 
%    * compute P values properly
%    ** Monte-Carlo method to compute the p-value of a distribution, based on
%       the KS distance 
%    ** search for specific tests for each distribution 
%    ** Anderson–Darling test (not in Matlab) 
%

function [ret] = distrtest_plot(type, x, no_plot)

type

if ~exist('no_plot', 'var')
    no_plot = 0; 
end 

% Quantile to show using horizontal lines
alphaprec = 0.05; 

line_width = 4; 

colors = distrtest_colors(); 

n = length(x); 

x = sort(x);

r = (1:n)/n; 

% Show X/Y axis as logarithmic ; set by each distribution 
log_x = 0;
log_y = 0; 

% Other fields are filled by each distribution 
ret = struct();
ret.n = length(x);

% The used expressions for y are the inverse cumulative distribution
% functions 
switch type

  case 'normal'
    % Normal distribution 
    y = erfinv(r * 2 - 1); 

    [h p] = lillietest(x); 
    ret.p = p;

    mu = mean(x); 
    v = var(x);

    ret.k = 2;
    ret.params = [mu sqrt(v)]; 
    ret.param_names = { 'mu', 'sigma' };
    ret.D = ksdist(x, @(X)(0.5 * (1 + erf((X - mu) / (2 * v))))); 
    ret.L_log = -0.5 * n * log(2 * pi * v) - (n - 1) / 2;
    
  case 'lognormal'
    % Lognormal distribution 
    y = erfinv(r * 2 - 1); 
    log_x = 1; 

    [h p] = lillietest(log(x));
    ret.p = p;

    mu = mean(log(x));
    v = var(log(x)); 

    ret.k = 2;
    ret.params = [mu sqrt(v)]; 
    ret.param_names = { 'mu', 'sigma' }; 
    ret.D = ksdist(x, @(X)(0.5 * (1 + erf((log(X) - mu) / (2 * v))))); 
    ret.L_log = - n * mu - 0.5 * n * log(2 * pi * v) - (n - 1) / 2;
    
  case 'logistic'
    % Logistic distribution 
    % Note: this can also be written as y = 2 artanh(2 * r - 1)
    y = -log(1 ./ r - 1); 

    ret.k = 2;
    [phat pci] = mle(x, 'distribution', 'logistic');
    p_mu = phat(1);
    p_s = phat(2);
    ret.params = [ p_mu p_s ];
    ret.param_names = { 'mu', 's' };
    ret.param_ci = pci; 

    ret.D = ksdist(x, @(X)(1 ./ (1 + exp(- (X - p_mu) ./ p_s))));
    x_norm = - (x - p_mu) / p_s;
    ret.L_log = - n * log(p_s) + sum(x_norm) - 2 * sum(ln_spec(x_norm)); 

  case 'loglogistic'
    % Log-logistic distribution
    % Note: this can also be written as y = 2 artanh(2 * r - 1)
    y = -log(1 ./ r - 1); 
    log_x = 1; 

    ret.k = 2;
    [phat pci] = mle(x, 'distribution', 'loglogistic');
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

    ret.D = ksdist(x, @(X)(1 ./ (1 + (x / p_alpha) .^ p_beta)));
    ret.L_log = n * log(p_beta) - n * p_beta * p_mu + (p_beta - 1) * sum(log(x)) - 2 * sum(ln_spec((log(x) - p_mu) / p_s));

  case 'cauchy'
    % Cauchy distribution 
    y = tan(pi * (r - 1/2));

  case 'logcauchy'
    % Log-Cauchy distribution
    y = tan(pi * (r - 1/2));
    log_x = 1;

  case 'gumbel'
    % Gumbel distribution
    % Note:  The Weibull distribution can be characterized as the log-Gumbel distribution.
    y = log(-log(1 - r)); 

  case 'weibull'
    % Weibull distribution
    y = log(-log(1 - r)); 
    log_x = 1; 
    
    [parmhat parmci] = wblfit(x);
    p_lambda = parmhat(1);
    p_k = parmhat(2); 
    ret.params = [ p_lambda p_k ];
    ret.param_ci = parmci; 
    ret.param_names = {'lambda', 'k'};
    ret.k = 2;
    ret.D = ksdist(x, @(X)(wblcdf(X, p_lambda, p_k)));
    ret.L_log = n * log(p_k) - n * p_k * log(p_lambda) + (p_k - 1) * sum(log(x)) - sum((x / p_lambda) .^ p_k); 

  case 'hsd'
    % Hyperbolic secant distribution 
    y = (2/pi) * log(tan((pi/2)*r)); 

  case 'loghsd'
    % Log-hyperbolic secant distribution"
    y = (2/pi) * log(tan((pi/2)*r)); 
    log_x = 1; 

  case 'exp'
    % Exponential distribution
    y = -log(1 - r);
    log_x = 1;
    log_y = 1;
    
    [h p] = lillietest(x, 0.05, 'exp');
    ret.p = p;

    ret.k = 1;
    lambda = 1 / mean(x);
    ret.params = [ lambda ];
    ret.param_names = { 'lambda' };
    ret.L_log = n * log(lambda) - lambda * sum(x); 
    ret.D = ksdist(x, @(X)(1 - exp(-lambda * X)));

  case 'pareto'
    % Pareto distribution
    y = -log(1 - r);
    log_x = 1;

    % Note:  min(x) is not necessarily a good estimator ofthe
    % parameter x_min of the Pareto distribution.
    [h p] = lillietest(log(x / min(x)), 0.05, 'exp');
    ret.p = p;

  case 'gamma'
    % Gamma distribution
    [phat pci] = gamfit(x); 
    p_k = phat(1);     % = \alpha 
    p_theta = phat(2); % = 1 / \theta
    ret.params = [p_k p_theta]; 
    ret.param_names = { 'k', 'theta' }; 
    ret.param_ci = pci;
    y = gammaincinv(r, p_k);
    log_x = 1;
    log_y = 1; 

    ret.k = 2;
    ret.D = ksdist(x, @(X)(gamcdf(X, p_k, p_theta)));
    ret.L_log = - n * p_k * log(p_theta) - n * gammaln(p_k) + (p_k - 1) * sum(log(x)) - p_theta * sum(x);

  case 'beta'
    % Beta distribution
    [phat pci] = betafit(x);
    alpha = phat(1);
    beta = phat(2);
    ret.params = [alpha beta]; 
    ret.param_names = { 'alpha', 'beta' };
    ret.param_ci = pci;
    y = betaincinv(r, alpha, beta);
    log_x = 1;
    log_y = 1; 

    ret.k = 2;
    ret.D = ksdist(x, @(X)(betacdf(X, alpha, beta)));
    ret.L_log = - n * betaln(alpha, beta) + (alpha - 1) * sum(log(x)) + (beta - 1) * sum(log(1 - x));

  case 'burr'
    % Not supported in our version of Matlab
    [phat pci] = mle(x, 'distribution', 'Burr');
    p_alpha = phat(1);
    p_c = phat(2);
    p_k = phat(3);
    y = ((1 - r) .^ (-1 / p_k) - 1) ^ (1 / p_c);
    ret.k = 2;
    ret.params = [ p_alpha p_c p_k ];
    ret.param_names = { 'alpha', 'c', 'k' };
    ret.param_ci = pci;
    ret.D = ksdist(x, @(X)(1 - (1 + (X / p_alpha) .^ p_c) .^ (- p_k)));
    x_ln_alpha = log(x / p_alpha); 
    ret.L_log = n * log(p_k * p_c / p_alpha) + (p_c - 1) * sum(x_ln_alpha) - (p_k + 1) * sum(ln_spec(p_c * x_ln_alpha)); 

  case 'halfnormal'
    p_sigma = sqrt(sum(x .^ 2) / n);
    y = erfinv(r);
    log_x = 1;
    log_y = 1; 
    ret.k = 1;
    ret.params = [ p_sigma ];
    ret.param_names = { 'sigma' };
    ret.D = ksdist(x, @(X)(erf(X / (sqrt(2) * p_sigma))));
    ret.L_log = 0.5 * n * log((2 / pi) * (p_sigma .^ -2)) - sum(x .^ 2) / (2 * p_sigma^2);

  case 'gengamma'
    % Generalized Gamma distribution 
    phat = fitgengam(x) % This function is from WAFO (version 25)
    if ~isnan(phat.params(1))
        p_alpha = phat.params(1); % Name in WAFO:  a;   Name in Wikipedia:  d/p
        p_beta  = phat.params(2); % Name in WAFO:  b;   Name in Wikipedia:  a
        p_gamma = phat.params(3); % Name in WAFO:  c;   Name in Wikipedia:  p
        ret.k = 3;
        ret.params = [ p_alpha p_beta p_gamma ];
        ret.param_names = { 'alpha', 'beta', 'gamma' };
        ret.L_log = phat.loglikemax;
        ret.p = phat.pvalue;
        ret.D = ksdist(x, @(X)(cdfgengam(X, p_alpha, p_beta, p_gamma)));
        y = gammaincinv(r, p_alpha);
    else
        y = NaN; 
    end

  case 'poisson'
    % The Poisson distribution
    % This is the only discrete distribution considered here 
    p_lambda = mean(x);
    ret.k = 1;
    ret.params = [ p_lambda ];
    ret.param_names = { 'lambda' };
    ret.L_log = log(p_lambda) * sum(x) - sum(gammaln(x + 1)) - n * p_lambda;
    y = gammaincinv(r, p_lambda);
    
  otherwise
    error(sprintf('*** Invalid distribution %s', type)); 
end

%
% Information criteria
%

if isfield(ret, 'L_log') 
    ret.A = 2 * ret.k - 2 * ret.L_log + 2 * ret.k * (ret.k + 1) / (n - ret.k - 1); 
    ret.B = ret.k * log(n) - 2 * ret.L_log; 
end

%
% Plot
%

% This should be the case anyway, but it is not e.g. for cauchy
if ~no_plot & length(y) > 1
    y(end) = +Inf; 

    stairs(x, y, 'Color', colors.(type), 'LineWidth', line_width);

    if log_x
        set(gca, 'XScale', 'log'); 
    end

    if log_y
        set(gca, 'YScale', 'log'); 
    end

    y_grid = [y(ceil(alphaprec*n)) y(floor((1-alphaprec)*n))]; 
    ax = axis();
    line([ax(1) ax(2)], [y_grid(1) y_grid(1)], 'LineStyle', '--', 'Color', [.7 .7 .7]); 
    line([ax(1) ax(2)], [y_grid(2) y_grid(2)], 'LineStyle', '--', 'Color', [.7 .7 .7]); 

    %
    % Show statistics
    %
    if isfield(ret, 'p')
        text(ax(1), ax(3), sprintf('p = %g', ret.p), ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    end
    if isfield(ret, 'D')
        text(ax(2), ax(3), sprintf('D = %g', ret.D), ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom'); 
    end
    if isfield(ret, 'A')
        text(ax(1), ax(4), sprintf('A = %g ; B = %g', ret.A, ret.B), ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    end

end
    
end

%
% Compute y = log(1 + exp(x)) in a way that's accurate for both very
% small and very large x. 
%
function y = ln_spec(x)

y = ((x < 0) .* (log(1 + exp(x)))) + ((x >= 0) .* (x + log(1 + exp(-x))));

end
