%
% Draw a single bar chart of link prediction results.
%
% PARAMETERS 
%	methods_arg		(n*1) Cellstrings of methods; may be [] to omit the method names
%	submethods	(n*1) Cellstrings of submethods 
%	precisions	(n*1) Precision values 
%	measure		The measure used
%

function precisions_plot(methods_arg, submethods, precisions, measure)

font_size = 16; 
font_size_min = 4; 
rotation = 60; 

labels_measure = get_labels_measure(); 

n = size(precisions,1) 

if n == 0
    plot(0,0);
    return; 
end

[colors line_styles markers] = styles_submethod(); 
labels_submethod = get_labels_submethod(); 
labels_method = get_labels_method(); 

labels = []; 
cm = [ ]; 

for k = 1:n
    submethod = submethods(k,1);  submethod = submethod{:} 
    label_submethod = labels_submethod.(submethod); 
    if length(methods_arg)
        methods_arg
        method = methods_arg(k,1); method = method{:} 
        label_method = labels_method.(regexprep(method, '-', '_'));
        label = sprintf('%s %s', label_method, label_submethod); 
    else
        label = label_submethod; 
    end
            
    color_k = colors.(submethod);
    cm = [cm; color_k]; 
    labels = [ labels ; cellstr(label) ]; 
end

hold on; 
for k = 1:n
    l = zeros(1,n);
    l(k) = precisions(k);
    h = bar(l);
    set(h, 'FaceColor', cm(k,:)); 
end
set(gca, 'FontSize', font_size); 
ylabel(labels_measure.(measure), 'FontSize', font_size);

ax = axis()
ax(2) = n+1;
ax(3) = max(0, min(precisions) - 0.05 * (max(precisions) - min(precisions))); 
if ax(3) == ax(4), ax(3) = 0; ax(4) = 1; end; 
ax
axis(ax);
xticklabel_rotate(1:n, rotation, labels, 'FontSize', max(font_size_min, 20 - max(0, floor(0.6 * (n-10))))); 

