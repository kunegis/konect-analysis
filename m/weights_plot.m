%
% Plot the edge weight and multiplicity distributions of a network.   
%
% PARAMETERS 
%	$network	Network name, must not have format UNWEIGHTED
%
% INPUT FILES 
%	dat/data.$network.mat
%
% OUTPUT FILES 
%	plot/weights.{a}.$network.eps 
%

network = getenv('network');

font_size = 22; 

consts = konect_consts(); 
colors = konect_colors_letter(); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 

%
% (b) Edge weight distribution
%
if info.weights ~= consts.UNWEIGHTED & info.weights ~= consts.POSITIVE ...
        & info.weights ~= consts.DYNAMIC

    ws = data.T(:,3); 

    wsi = min(ws);
    wsa = max(ws); 

    values = unique(ws); 

    if length(values) <= 12

        values 

        counts = histc(ws, [-Inf; (0.5 * (values(1:end-1) + values(2:end))); +Inf])
        bar(values, counts(1:end-1), 'FaceColor', colors.weight, 'EdgeColor', colors.weight); 

    else

        step = (wsa - wsi) / 50; 
        hist(ws, wsi:step:wsa);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor', colors.weight, 'EdgeColor', colors.weight)

        ax = axis(); 
        ax(1) = wsi - 0.15 * (wsa-wsi);
        ax(2) = wsa + 0.15 * (wsa-wsi); 
        axis(ax); 

        if wsa - wsi <= 10
            set(gca, 'XTick', round(wsi):round(wsa)); 
        else
            set(gca, 'XTick', round(wsi):10:round(wsa)); 
        end

    end

    set(gca, 'FontSize', font_size); 
    
    xlabel('Edge weight (w)', 'FontSize', font_size); 
    ylabel('Frequency', 'FontSize', font_size); 

    set(gca, 'YGrid', 'on'); 

    konect_print(sprintf('plot/weights.b.%s.eps', network));

end

%
% (c), (d) - Edge multiplicity distribution 
%
        
if info.weights == consts.POSITIVE | info.weights == consts.MULTIWEIGHTED

    if info.weights == consts.POSITIVE
        T = data.T;
        if size(T,2) > 3,  T = T(:,1:3);  end;
    else % MULTIWEIGHTED
        T = data.T(:,1:2); 
    end

    if size(T,2) >= 3
        A = sparse(T(:,1), T(:,2), T(:,3), info.n1, info.n2); 
    else
        A = sparse(T(:,1), T(:,2), 1, info.n1, info.n2); 
    end

    if info.format == consts.SYM
        A = A + A';
        A = triu(A);
    end

    [x y ws] = find(A); 
    x = [];
    y = []; 

    degree_print(ws, NaN, NaN, NaN, 'Edge multiplicity (w)', 'weight');
    konect_print(sprintf('plot/weights.c.%s.eps', network)); 

    konect_plot_power_law(ws, [], 0, colors.weight);

    xlabel('Edge multiplicity (w)', 'FontSize', font_size);
    ylabel('P(x \geq w)', 'FontSize', font_size); 
    konect_print(sprintf('plot/weights.d.%s.eps', network)); 
        
end

%
% (a) - Placeholder plot 
%

plot(0);
konect_print(sprintf('plot/weights.a.%s.eps', network)); 
