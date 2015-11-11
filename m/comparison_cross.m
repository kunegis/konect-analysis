%
% Plot and print a cross-method comparison plot.
%
% PARAMETERS 
%	prec			(m*n) Precision values 
%	filename_a, filename_a_bw, filename_b, filename_b_bw, filename_legend, filename_legend_bw
%				Filename of plots 
%	labels_method_id	(m) Names of methods
%	labels_network_id	(n)
%	label_measure
%

function comparison_cross(prec, ...
                          filename_a, filename_a_bw, filename_b, filename_b_bw, filename_legend, filename_legend_bw, ...
                          colormap_b, colormap_b_bw, labels_method_id, labels_network_id, ...
                          label_measure) 

[m n] = size(prec) 

assert(length(labels_method_id) == m);
assert(length(labels_network_id) == n);

% Maximal number of methods to show
max_methods = 30; 

% Map -Inf to -1. 
for j = 1 : m
    prec(j, isinf(prec(j,:))) = -1;  
end

% Normalize to zero mean precision by network
prec_norm = prec;
for j = 1 : n
    line = prec_norm(:,j);
    line = line(~isnan(line));
    prec_norm(:,j) = prec_norm(:,j) - mean(line); 
end

% Order methods				  
for j = 1 : m
    line = prec_norm(j,:);
    line = line(~isnan(line)); 
    average(j) = mean(line); 
end
[tmp ii] = sort(average, 'descend'); 
m_cut = min(max_methods, m);
ii_cut = ii(1 : m_cut); 

% Order networks
for j = 1 : n
    col = prec(:,j);
    col = col(~isnan(col));
    average_col(j) = mean(col); 
end
[tmp jj] = sort(average_col, 'descend');  

% Order both 
prec_sorted = prec(ii_cut, jj);

%
% (b) Method by network matrix
%

font_size = 10; 

imagesc(prec_sorted');
h = colorbar;
colormap(colormap_b); 
label_measure
ylabel(h, label_measure); 
xticklabel_rotate(1:m_cut, 90, labels_method_id(ii_cut), 'FontSize', font_size); 
set(gca, 'YTickLabel', labels_network_id(jj), 'YTick', 1:n); 
set(gca, 'TickLength', [0 0]); 
axis image

konect_print(filename_b); 

imagesc(prec_sorted');
h = colorbar;
colormap(colormap_b_bw); 
label_measure
ylabel(h, label_measure); 
xticklabel_rotate(1:m_cut, 90, labels_method_id(ii_cut), 'FontSize', font_size); 
set(gca, 'YTickLabel', labels_network_id(jj), 'YTick', 1:n); 
set(gca, 'TickLength', [0 0]); 
axis image

konect_print(filename_b_bw); 


%
% (a) Method by method matrix
%

p_threshold = 0.05;
maxdiff = 0.2; 

konect_significance_plot(prec_sorted, p_threshold, maxdiff, labels_method_id(ii_cut)); 

konect_print(filename_a); 

%
% (legend) Legend
%

konect_significance_legend(p_threshold, maxdiff, label_measure);

konect_print(filename_legend); 

%
% (a-bw) Method by method matrix
%

p_threshold = 0.05;
maxdiff = 0.1; 

konect_significance_plot_bw(prec_sorted, p_threshold, maxdiff, labels_method_id(ii_cut)); 

konect_print(filename_a_bw); 

%
% (legend-bw) Legend
%

konect_significance_legend_bw(p_threshold, maxdiff, label_measure);

konect_print(filename_legend_bw); 
