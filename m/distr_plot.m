%
% Plot the eigenvalue distribution.
%
% PARAMETERS 
%	$network
%	$decomposition
%
% INPUT FILES 
%	dat/distr.$decomposition.$network
%
% OUTPUT FILES 
%	plot/distr.$decomposition.[abf].$network.eps
%		(a) Plain distribution
%		(b) Stairs, i.e. transposed cumulative distribution
%		(f) Cumulative distribution
%

%
% Compute distribution
%

font_size = 22; 
line_width = 3; 

%%color_half = [117 255   0] / 255;
%%color_full = [136   0 255] / 255; 

value_name = 'Eigenvalue';
value_symbol = '\lambda';

network = getenv('network');
decomposition = getenv('decomposition'); 

[data_decomposition colors_decomposition] = konect_data_decomposition(decomposition)
field_name= regexprep(decomposition, '-', '_'); 
color = colors_decomposition.(field_name) 

data = load(sprintf('dat/distr.%s.%s', decomposition, network)); 

counts = data(:,1);
begins = data(:,2);
ends = data(:,3);

%
% Don't show zero eigenvalues.  In fact, this will remove approximately-zero eigenvalues. 
%
counts_nz = counts;
for i = 1 : length(counts_nz)
    if begins(i) <= 0 & ends(i) >= 0
        counts_nz(i) = 0; 
    end
end


%
% (b) Stairs
% 

stairs([0; cumsum(counts_nz)], [(.5 * (begins+ends)); (.5 * (begins(end)+ends(end)))]); 
xlabel('k', 'FontSize', font_size); 
ylabel(sprintf('%s_k', value_symbol), 'FontSize', font_size);

set(gca, 'FontSize', font_size);

konect_print(sprintf('plot/distr.%s.b.%s.eps', decomposition, network)); 

%
% (f) Cumulative
%

hold on; 

ccounts = cumsum(counts_nz / sum(counts_nz)); 
stairs([begins; ends(end)], [ccounts; ccounts(end)], '-', 'LineWidth', line_width, 'Color', color);
stairs(ends, ccounts, '-', 'LineWidth', line_width, 'Color', color); 

xlabel(sprintf('%s (%s)', value_name, value_symbol), 'FontSize', font_size);
ylabel(sprintf('P(x \\leq %s)', value_symbol), 'FontSize', font_size);

set(gca, 'FontSize', font_size); 

axis([begins(1) ends(end) 0 1]); 

grid on; 
		
konect_print(sprintf('plot/distr.%s.f.%s.eps', decomposition, network)); 


%
% (a) Plain
% 

bar(.5 * (begins+ends), counts, 'g'); 
xlabel(sprintf('%s (%s)', value_name, value_symbol), 'FontSize', font_size); 
ylabel('Frequency', 'FontSize', font_size); 

set(gca, 'FontSize', font_size);

ax = axis()
ax(4) = max(counts_nz * 1.05); 
if ax(4) > 0
    axis(ax); 
end

konect_print(sprintf('plot/distr.%s.a.%s.eps', decomposition, network)); 
