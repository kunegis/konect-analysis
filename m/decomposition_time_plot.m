%
% Plot the spectrum over time.
%
% PARAMETERS 
%	$TYPE		"full" or "split"
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
% 	dat/decomposition_time.$TYPE.$DECOMPOSITION.$NETWORK.mat
%	dat/decomposition_time_runtime.$TYPE.$DECOMPOSITION.$NETWORK
%	dat/stepsi.$NETWORK (full only)
%	dat/steps.$NETWORK.mat (split only) 
%	
% OUTPUT 
%	plot/decomposition_time.$TYPE.[abt].$DECOMPOSITION.$NETWORK.eps
%		See below for types
%

marker_size = 10; 
marker = '.'; 
font_size = 22; 

network = getenv('NETWORK'); 
decomposition = getenv('DECOMPOSITION'); 
type = getenv('TYPE'); 
is_split = strcmp(type, 'split'); 

decomposition_time = load(sprintf('dat/decomposition_time.%s.%s.%s.mat', type, decomposition, network));

if ~is_split
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else
    steps_data = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps_data.e_steps; 
end

times = load(sprintf('dat/decomposition_time_runtime.%s.%s.%s', type, decomposition, network)); 

decompositions = decomposition_time.decompositions;
r = decomposition_time.r; 

info = read_info(network); 

data_decomposition = konect_data_decomposition(decomposition, info.format); 

%
% (t) Runtime
%

plot(e_steps, times, 'o-r'); 

xlabel('Volume (|E|)');
ylabel('Runtime [s]');

if is_split
    points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
    gridxy(points, [0], 'LineStyle', '--'); 
end

konect_print(sprintf('plot/decomposition_time.%s.t.%s.%s.eps', type, decomposition, network)); 

%
% (b) Absolute spectrum
%

s_end = diag(decompositions(end).D);

if ~isreal(s_end) | sum(s_end < 0)

    hold on;

    for k = 1 : r

        spectrum = NaN * zeros(prod(size(e_steps)),1); 
        
        for l = 1 : prod(size(decompositions))
            % Each decomposition may have a different size.  
            if k <= size(decompositions(l).D, 1)
                value = decompositions(l).D(k,k);

                % The color denotes the argument, with green for 1, red for -1,
                % yellow for +i and blue for -i.  
                a = angle(value) / pi;
                if a >= 0 
                    color = [ a (1-a) 0 ];
                elseif a >= -0.5
                    color = [ 0 (1+2*a) (-2*a) ];
                else
                    color = [ (-2*a-1) 0 (2*a+2) ]; 
                end
                color 

                plot(e_steps(l), abs(value), marker, 'MarkerSize', marker_size, 'Color', color); 
            end
        end
    end

    xlabel('Volume (|E|)');
    ylabel('Spectrum'); 

    if is_split
        points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
        gridxy(points, [0], 'LineStyle', '--'); 
    end

    konect_print(sprintf('plot/decomposition_time.%s.b.%s.%s.eps', type, decomposition, network)); 
end

%
% (a) Real part
%

hold on;

for k = 1 : r

    spectrum = NaN * zeros(prod(size(e_steps)),1); 
    
    for l = 1 : prod(size(decompositions))
        % Each decomposition may have a different size.  
        if k <= size(decompositions(l).D, 1)
            spectrum(l) = decompositions(l).D(k,k);
        else
            spectrum(l) = NaN; % No k'th eigenvalue at this timepoint
        end
    end

    spectrum = spectrum_visualize(spectrum, decomposition); 

    plot(e_steps, spectrum, 'Marker', marker, 'LineStyle', 'none', 'Color', [ 0 0 0 ], 'MarkerSize', marker_size); 

end

ax = axis();
ax(2) = max(e_steps); 
axis(ax); 

xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
ylabel(sprintf('%ss (%s[%s])', data_decomposition.value_name, ...
               data_decomposition.value_symbol, data_decomposition.matrix), 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

set(gca, 'YGrid', 'on'); 

if is_split
    points = [e_steps(steps_data.steps_source) e_steps(steps_data.steps_source + steps_data.steps_target)] 
    gridxy(points, [0], 'LineStyle', '--'); 
end

set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/decomposition_time.%s.a.%s.%s.eps', type, decomposition, network)); 
