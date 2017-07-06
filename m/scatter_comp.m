%
% Draw scatter plots.
%
% PARAMETERS 
%	$networks	Space-separated list of networks
%	$kind		Kind of plot:  Names of two statistics separated by a dot '.'
%	$class		Name of class used (corresponds to choice of networks)
%
% INPUT FILES
%	Depending on the kind
%
% OUTPUT FILES
%	plot/scatter.[a...].$kind.$class.eps
%	plot/scatter_single.[a...].$statistic_y.$class.eps (when $statistic_x == volume)
%	dat/scattercorr.$kind.$class
%

networks = getenv('networks');
kind = getenv('kind');
class = getenv('class'); 

networks = regexp(networks, '[a-zA-Z0-9_-]+', 'match')

if length(networks) == 0
    plot(0);
    konect_print(sprintf('plot/scatter.a.%s.%s.eps', kind, class)); 
    exit;
end

tokens = regexp(kind, '^(.+)\.(.+)$', 'tokens');
statistic_x = tokens{1}(1); statistic_x = statistic_x{:}
statistic_y = tokens{1}(2); statistic_y = statistic_y{:}

% One network per line.  Columns:  X, Y, FORMAT, WEIGHTS. 
s = [];

for k = 1 : prod(size(networks))
    network = networks(k); 
    network = network{:}

    info = read_info(network); 

    x = read_statistic(statistic_x, network);   x = x(1); 
    y = read_statistic(statistic_y, network);   y = y(1); 

    s = [ s ; x y info.format info.weights ]; 
end

x_label = konect_label_statistic(statistic_x, 'matlab');
y_label = konect_label_statistic(statistic_y, 'matlab'); 

% For some combinations of statistics, both axes show the same type of
% variable, and thus we draw square plots with the main diagonal (X=Y)
% visible.  
equal_axes = 0;
if strcmp(statistic_x, 'size_2') & strcmp(statistic_y, 'size_3'), equal_axes = 1;  end; 

[logarithmic] = konect_data_statistic();

statistic_x_field = konect_tofieldname(statistic_x);
statistic_y_field = konect_tofieldname(statistic_y);

x_log = logarithmic.(statistic_x_field);
y_log = logarithmic.(statistic_y_field); 

s_1 = s(:,1)'; 
s_2 = s(:,2)'; 
s_3 = s(:,3)'; 
s_4 = s(:,4)'; 

%
% Distribution of values for Y statistic
%
if strcmp(statistic_x, 'volume')
    scatter_single(s(:,2), class, 'a', y_label, y_log, statistic_y); 
    scatter_single(s(:,2), class, 'b', y_label, y_log, statistic_y); 
    scatter_single(s(:,2), class, 'bx', y_label, y_log, statistic_y); 
    scatter_single(s(:,2), class, 'by', y_label, y_log, statistic_y); 
    scatter_single(s(:,2), class, 'bxy', y_label, y_log, statistic_y); 
end


%
% Correlation values
%

s_1 = s(:,1)
s_2 = s(:,2)
ii = isfinite(s_1) & isfinite(s_2)

[corr_rho corr_pval] = corr(s_1(ii), s_2(ii))

OUT = fopen(sprintf('dat/scattercorr.%s.%s', kind, class), 'w'); 
if OUT < 0, error('fopen'); end;
fprintf(OUT, '%g\n%g\n', corr_rho, corr_pval); 
if fclose(OUT) < 0, error('fclose'); end;

%
% Actual plots
%

types = { 'c', 'b', 'bx', 'by', 'bxy', 'v', 'w', 'a' }; 

for i = 1 : length(types)
    type = types{i}
    scatter_plot(s, kind, class, type,   x_label, y_label, equal_axes, networks, x_log, y_log, statistic_x, statistic_y);
end
