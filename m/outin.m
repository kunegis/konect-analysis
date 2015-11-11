%
% Plot the outdegree vs the indegree of all nodes.  Only for directed
% networks. 
%
% PARAMETERS 
%	$NETWORK	Network name
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	plot/outin.[a].$NETWORK.eps	Plots
%

font_size = 22; 

consts = konect_consts(); 

network = getenv('NETWORK'); 

info = read_info(network); 

assert(info.format == consts.ASYM); 

data = load(sprintf('dat/data.%s.mat', network)); 

if info.weights == consts.POSITIVE & size(data.T, 2) >= 3
    w = data.T(:,3);
else
    w = 1; 
end

% Outdegrees 
d_1 = sparse(data.T(:,1), 1, w, info.n1, 1);

% Indegrees
d_2 = sparse(data.T(:,2), 1, w, info.n2, 1); 

%
% (b) - logarithmic axes
%

loglog(d_1, d_2, '.');

xlabel('Outdegree (d_1)', 'FontSize', font_size); 
ylabel('Indegree (d_2)', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis(); 
ax(1) = 0.7;
ax(3) = 0.7;
axis(ax); 
if ax(1) > 0 & ax(3) > 0 
    set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
    set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
end

konect_print(sprintf('plot/outin.b.%s.eps', network)); 

%
% (c) - shifted logarithmic axes
%

loglog(d_1 + 1, d_2 + 1, '.');

xlabel('Augmented outdegree (1 + d^+)', 'FontSize', font_size); 
ylabel('Augmented indegree (1 + d^-)', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis(); 
ax(1) = 0.7;
ax(3) = 0.7;
axis(ax); 
if ax(1) > 0 & ax(3) > 0 
    set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
    set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
end

konect_print(sprintf('plot/outin.c.%s.eps', network)); 

%
% (a) - normal axes
%
plot(d_1, d_2, '.');
konect_print(sprintf('plot/outin.a.%s.eps', network)); 
