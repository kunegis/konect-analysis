%
% Draw one scatter distribution, i.e., a distribution plot for the
% values of one single statistic.
%
% PARAMETERS 
% 	s		(n*1) Values of the statistic for all networks
%	class		Class name 
%	type		Type of plot
%		a - Normal
%		b - Bare - only points and frame. No labels. Square
%		aspect ratio. 
%		bx - Bare, with X axis label
%		by - Bare, with Y axis label
%		bxy - Bare, with both axis labels 
%	label		Label of the statistic
%	log_axis	(0/1) Whether to use a logarithmic axis
%	statistic	The statistic
%
% OUTPUT 
%	plot/scatter_single.$TYPE.$STATISTIC.$CLASS.eps 
%

function scatter_single(s, class, type, label, log_axis, statistic)

'scatter_single'
type

font_size_label_nosubscript = 22; 
font_size_label_subscript = 16; 
font_size_axis_b = 28; 

color = [ 0.5 0.5 0.5 ]; 

k = length(s)

nbins = floor(k / 3);
nbins = max(nbins, 10); 
nbins = min(nbins, 100); 

ax12 = axis_fit(s, log_axis); 

%if log_axis

if log_axis
    edges = exp(log(ax12(1)) : ((log(ax12(2)) - log(ax12(1))) / nbins) : log(ax12(2))); 
else
    edges = ax12(1) : ((ax12(2)) - ax12(1)) / nbins : ax12(2); 
end

    [n, bin] = histc(s, edges); 
    b = bar(edges, n, 'histc'); 
    delete(findobj('marker','*'));

    if log_axis
        set(gca, 'XScale', 'log'); 
    end
    set(b, 'FaceColor', color);

    %else
    %    hist(s, nbins);
    %    h = findobj(gca,'Type','patch');
    %    h.FaceColor = color;

    %end

%
% Axis
% 

ax = axis(); 
ax(1:2) = ax12; 
axis(ax); 

if type(1) == 'b'
    pbaspect([1 1 1]); 
end

%
% Labels
%

if strfind(label, '_')
    font_size_label = font_size_label_subscript;
else
    font_size_label = font_size_label_nosubscript;
end

if type(1) ~= 'b'
    xlabel(label, 'FontSize', font_size_label); 
end

%
% Ticks 
%

if type(1) == 'b'
    set(gca, 'YTick', [], 'YTickLabel', ''); 
    if ~( strcmp(type, 'bx') | strcmp(type, 'bxy') )
        set(gca, 'XTickLabel', ''); 
    else
        set(gca, 'FontSize', font_size_axis_b); 
    end
end

set(gca, 'TickLength', [0.05 0.05]); 

konect_print(sprintf('plot/scatter_single.%s.%s.%s.eps', type, statistic, class)); 
