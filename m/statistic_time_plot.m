%
% Plot the evolution of a network statistic over time. 
%
% PARAMETERS 
%	$TYPE			"full" or "split"
%	$NETWORK
%	$STATISTIC
%	$DISABLE_RUNTIME	"1" to not generate the runtime plots
%				(runtime data is not generated for
%				spectral statistics)    
%
% INPUT 
%	dat/statistic_time.$TYPE.$STATISTIC.$NETWORK
%	dat/statistic_time_runtime.$TYPE.$STATISTIC.$NETWORK
%	dat/stepsi.$NETWORK (full only)
%	dat/steps.$NETWORK.mat (split only) 
%
% OUTPUT 
%	plot/statistic_time.$TYPE.[abt].$STATISTIC.$NETWORK.eps
%		a - main plot
%		b - bare plot
%		c - main plot restricted to the test set (only for $TYPE = split)
%		cb - bare plot restricted to the test set (only for $TYPE = split)
%		t - runtime plot
%

network = getenv('NETWORK'); 
statistic = getenv('STATISTIC'); 
type = getenv('TYPE'); 
is_split = strcmp(type, 'split'); 
disable_runtime = getenv('DISABLE_RUNTIME'); 
disable_runtime = strcmp(disable_runtime, '1'); 

font_size = 22; 
color_test = [ 0 .7 0 ]; 

data = load(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network));

if ~is_split
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else
    steps_data = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps_data.e_steps; 
    range_test = (1 + steps_data.steps_source + steps_data.steps_target) : length(e_steps); 
end

if ~disable_runtime
    times = load(sprintf('dat/statistic_time_runtime.%s.%s.%s', type, statistic, network)); 
end

%
% (t) Runtime
%

if ~disable_runtime
  plot(e_steps, times, 'o-r'); 

  % The first few runs may be very skewed; don't need to have them on the plot 
  ax = axis()
  ax(4) = 1.1 * (max(times(5:end)) - ax(3)) + ax(3);
  ax
  if ax(3) == ax(4), ax(4) = ax(3) * 1.05; end
  if ax(3) == ax(4), ax(4) = 1; end
  axis(ax); 

  xlabel(konect_label_statistic('volume', 'matlab'));
  ylabel(konect_label_statistic('runtime', 'matlab'));

  if is_split
    points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
    gridxy(points, [0], 'LineStyle', '--'); 
  end

  konect_print(sprintf('plot/statistic_time.%s.t.%s.%s.eps', type, statistic, network)); 
end

%
% (b) Bare plot
%

size_e_steps = size(e_steps)
size_data = size(data)

plot(e_steps, data(:,1), '-', 'LineWidth', 3);

% The first few points may be outliers; don't show them 
ax = axis(); 
ax(4) = 1.1 * (max(data(5:end,1)) - ax(3)) + ax(3)
if ax(4) > ax(3)
  axis(ax); 
end
			    
if is_split
  points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
  gridxy(points, [0], 'LineStyle', '--'); 
end

set(gca, 'XTick', [], 'YTick', []); 

konect_print(sprintf('plot/statistic_time.%s.b.%s.%s.eps', type, statistic, network));

%
% (cb) Bare test plot
%

if is_split
  plot(e_steps(range_test), data(range_test,1), '-', 'LineWidth', 4, 'Color', color_test);

  set(gca, 'XTick', [], 'YTick', []); 

  axis tight; 

  konect_print(sprintf('plot/statistic_time.%s.cb.%s.%s.eps', type, statistic, network));
end


%
% (c) Test plot
%

if is_split
    plot(e_steps(range_test), data(range_test,1), 'o-', 'LineWidth', 3, 'MarkerSize', 5, 'Color', color_test);

    xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
    ylabel(konect_label_statistic(statistic, 'matlab'), 'FontSize', font_size); 

    set(gca, 'FontSize', font_size); 

    part = 0.05; 
    ax = axis(); 
    dx = max(e_steps(range_test)) - min(e_steps(range_test)); 
    ax(1) = min(e_steps(range_test)) - dx * part;
    ax(2) = max(e_steps(range_test)) + dx * part; 
    axis(ax); 

    konect_print(sprintf('plot/statistic_time.%s.c.%s.%s.eps', type, statistic, network));
end

%
% (a) Main plot 
%

plot(e_steps, data(:,1), 'o-');

% The first few points may be outliers; don't show them 
ax = axis(); 
ax(4) = 1.1 * (max(data(5:end,1)) - ax(3)) + ax(3)
if ax(4) > ax(3)
    axis(ax); 
end
			    
xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
ylabel(konect_label_statistic(statistic, 'matlab'), 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

if is_split
    points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
    gridxy(points, [0], 'LineStyle', '--'); 
end

konect_print(sprintf('plot/statistic_time.%s.a.%s.%s.eps', type, statistic, network));

