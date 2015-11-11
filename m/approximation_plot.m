%
% Plot matrix approximations.
% 
% INPUT 
%	dat/approximation.$NETWORK.mat
%
% OUTPUT 
%	plot/approximation.$FUNCTION.$NETWORK.eps 
%		For all functions as given in the data file
%

network = getenv('NETWORK');

data = load(sprintf('dat/approximation.%s.mat', network)); 

[colors line_styles markers] = styles_method(); 

for j = 1 : length(data.functions)

    f = data.functions{j}

    hold on; 
    for i = 1 : size(data.prec.(f).values, 1)
        decomposition = data.decompositions{i}; 
        if strcmp(decomposition, 'svd'), continue; end; 
        plot(1 : size(data.prec.(f).values, 2), data.prec.(f).values(i, :), ...
             'LineStyle',  line_styles.(decomposition), 'Marker', markers.(decomposition), 'Color', colors.(decomposition), ...
             'LineWidth', 3); 
    end

    legend(data.names_decompositions, 'Location', 'EastOutside'); 

    xlabel('Decomposition rank (r)', 'FontSize', 16); 
    ylabel('Root mean squared error (RMSE)', 'FontSize', 16); 

    set(gca, 'FontSize', 16); 

    ax = axis(); 
    ax(4) = max(ax(4), 2.15e-4); 
    axis(ax); 

    konect_print(sprintf('plot/approximation.%s.%s.eps', f, network)); 
end
