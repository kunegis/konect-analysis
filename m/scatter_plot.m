%
% Draw and print one scatter plot.
%
% PARAMETERS 
%	s	(n*4) One row per network; columns:  X, Y, FORMAT, WEIGHTS. 
%	kind	What is plotted (only used for printing)
%	class	Only used for the filename
%	type	One letter plot type:
%		a	Abbreviations, colors by format
%		b	Bare - only black point frame.  No labels.  Square aspect ratio. 
%		bx	Bare with only X axis label
%		by	Bare with only Y axis label
%		bxy	Bare with both labels 
%		c	Abbreviations, colors by category 
%		w	Black and white version with markers (unique
%			only for bipartite networks)
%		v	Black and white version with letters 
%	x_label
%	y_label
%	equal_axes
%	networks	Network names 
%	x_log		X axis is logarithmic
%	y_log		Y axis is logarithmic 
%	statistic_x	The statistic shown on the X axis
%	statistic_y	The statistic shown on the Y axis 
%
function scatter_plot(s, kind, class, type, x_label, y_label, ...
                      equal_axes, networks, x_log, y_log, statistic_x, statistic_y)

font_size_label_nosubscript = 22; 
font_size_label_subscript = 16; 
font_size_axis_b = 28; 
font_size_name = 12; 

consts = konect_consts(); 

%
% Empty plot 
%
if size(s,1) <= 1
    plot(0,0); 
    konect_print(sprintf('plot/scatter.%s.%s.%s.eps', type, kind, class)); 
    return; 
end

%
% Correlation 
%
[rho, pval] = corr(s(:,1), s(:,2)) 

%
% Remove NaN
%
ii = (s(:,1) == s(:,1)) & (s(:,2) == s(:,2)); 

%
% Split into bipartite and unipartite
%
ib = find((s(:,3) == consts.BIP) & ii);
is = find((s(:,3) ~= consts.BIP) & ii);

hold on; 

%
% Axes
%

if  type(1) == 'b' || type(1) == 'a' || type(1) == 'c' || ...?
    type(1) == 'w' || type(1) == 'v'

    ax12 = axis_fit(s(:,1), x_log)
    ax34 = axis_fit(s(:,2), y_log)

    if 0 == ~isfinite([ ax12 ax34 ])
        axis([ ax12 ax34 ]); 
    end
end

if equal_axes
    ax = axis();
    line(ax(1:2), ax(3:4), 'LineStyle', '--', 'Color', [.4 .4 .4], 'LineWidth', 2); 
end

% 
% Labels / points 
%

if size(networks,2) < 10
    font_size_name = 20; 
end

for i = 1:size(networks,2)

    network = networks(i);
    network = network{:}

    metadata = read_meta(network); 

    if type(1) == 'i'
        display_name = metadata.name;
    else
        display_name = metadata.code; 
    end

    draw_first = 1; 
    if strcmp(type, 'power') | strcmp(type, 'power_detail')
        if size(regexp(network, '[_2-](ui|ti)$'))
            draw_first = 0; 
        elseif size(regexp(network, 'ut$')) 
            display_name = [display_name(1:end-2) '}']; 
        end
    end

    draw_one(type, s(i,1), s(i,2), display_name, network, font_size_name, s(i,3), metadata); 
end;

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis()
if ax(1) > 0 & ax(3) > 0
    if x_log
        set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
    end
    if y_log
        set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
    end
end

%
% Logarithmic axes
%

if x_log
    set(gca, 'XScale', 'log');
end

if y_log
    set(gca, 'YScale', 'log');
end

%
% Aspect ratio and square range 
%
if type(1) == 'b'
    pbaspect([1 1 1]); 
end

if equal_axes 
    axis square; 
    pbaspect([1 1 1]); 
end; 

%
% Axis labels
%
if strfind([x_label y_label], '_')
    font_size_label = font_size_label_subscript;
else
    font_size_label = font_size_label_nosubscript;
end

if type(1) ~= 'b'
    xlabel(x_label, 'FontSize', font_size_label);
end

if type(1) ~= 'b'
    ylabel(y_label, 'FontSize', font_size_label); 
end

set(gca, 'FontSize', font_size_label); 

%
% Ticks
%

if type(1) == 'b'

    set(gca, 'FontSize', font_size_axis_b); 

    if (~strcmp(type, 'bx')) & (~strcmp(type, 'bxy'))
        set(gca, 'XTickLabel', ''); 
    end

    if (~strcmp(type, 'by')) & (~strcmp(type, 'bxy'))
        set(gca, 'YTickLabel', ''); 
    end

else

    set(gca, 'XMinorTick', 'on');
    set(gca, 'YMinorTick', 'on'); 

end

set(gca, 'TickLength', [0.05 0.05]); 

%
% Legend 
%

if type(1) == 'x' || type(1) == 'i' 
    if size(ib,1) > 0
        if size(is,1) > 0
            legend('Bipartite dataset', 'Unipartite dataset', 'Location', 'Best'); 
        else
            legend('Bipartite dataset', 'Location', 'Best'); 
        end
    else
        legend('Unipartite dataset', 'Location', 'Best'); 
    end
end

%
% Statistic-specific elements
%

if strcmp(statistic_x, 'power')
    ax = axis();
    ax(2) = min(ax(2), 6); 
    axis(ax);
end
if strcmp(statistic_y, 'power')
    ax = axis();
    ax(4) = min(ax(4), 6); 
    axis(ax);
end

if strcmp(statistic_y, 'prefatt')
    gridxy([], [0 1], 'LineStyle', '--'); 
end


%
% Print
%

konect_print(sprintf('plot/scatter.%s.%s.%s.eps', type, kind, class)); 


end

%
% Draw one short name label 
%
function draw_one(type, x, y, display_name, network, font_size, format, metadata)

    marker_size = 17;

    consts = konect_consts(); 

    category = metadata.category; 
    [colors vertices edges markers letters] = konect_data_category(); 

    if type(1) == 'i'  % Full name
        text(x, y, ['  ' display_name]);

    elseif type(1) == 'a' || type(1) == 'c' || type(1) == 'v'  % Text

        if type(1) == 'a'
            t = display_name; 
            if format == consts.BIP,  color = [0  0  1]; end; 
            if format == consts.SYM,  color = [1  0  0]; end; 
            if format == consts.ASYM, color = [0  .8 0]; end; 
        elseif type(1) == 'c'
            t = display_name; 
            color = colors.(category); 
        elseif type(1) == 'v'
            t = letters.(category); 
            color = [ 0 0 0 ]; 
        else
            error('*** Invalid type');
        end

        plot(x, y, '.w'); % White point to scale the image correctly 
        text(x, y, t, 'FontSize', font_size, ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', color); 

    elseif type(1) == 'b' || type(1) == 'w' % Symbol 

        if type(1) == 'b'
            marker = 'o';
        elseif type(1) == 'w'
            marker = markers.(category); 
        else
            error('*** Invalid type');
        end

        plot(x, y, 'k', 'Marker', marker, 'MarkerSize', marker_size); 

    else
        error('*** Invalid type');
    end
end
