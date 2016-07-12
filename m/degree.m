%
% Draw degree and edge weight distributions.
%
% ENVIRONMENT 
% 	$network		Name of dataset, e.g. "advogato"
%	$ENABLE_POWER_LAW	"1" to draw the variants with power-law gamma estimation (flat)
%	$ENABLE_POWER_LAW_2	"1" to draw the variants with power-law gamma estimation (complex)
%	$ENABLE_POWER_LAW_3	"1" to draw the variants with power-law gamma estimation (p-values)
%
% INPUT 
%	dat/data.$network.mat
%	dat/info.$network
%	dat/statistic.power.$network	(only when $ENABLE_POWER_LAW is set)
%	dat/statistic.power2.$network	(only when $ENABLE_POWER_LAW_2 is set)
%	dat/statistic.power3.$network	(only when $ENABLE_POWER_LAW_3 is set)
%
% OUTPUT 
%
%	plot/degree.[auv]{,x,y,3}.$network.eps	Degree distributions
%		a - Degree of all nodes
%		u - Row-based (only BIP and ASYM)
%		v - Column-based (only BIP and ASYM)
%		x - Show the gamma estimation (flat)
%		y - Show the gamma estimation (complex)
%		3 - Show gamma and p-values (level 3) 
%
%	plot/degree.ms.[uv].$network.eps 	Mean vs. stddev
%

network = getenv('network');
enable_power_law = prod(size(getenv('ENABLE_POWER_LAW'))); 
enable_power_law_2 = prod(size(getenv('ENABLE_POWER_LAW_2'))); 
enable_power_law_3 = prod(size(getenv('ENABLE_POWER_LAW_3'))); 

font_size = 22; 

consts = konect_consts(); 

colors = konect_colors_letter(); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 
T = data.T; 
A = konect_spconvert(T, info.n1, info.n2); 

n1 = info.n1;
n2 = info.n2; 

if info.format == consts.SYM
    xmin = [ NaN ];
    pvalue = [ NaN ]; 
else
    xmin = [ NaN NaN NaN ]; 
    pvalue = [ NaN NaN NaN ];
end

if enable_power_law | enable_power_law_2 | enable_power_law_3
    enable_power_law_any = 1; 
    if enable_power_law
        data = load(sprintf('dat/statistic.power.%s', network))
        suffix = 'x';
    elseif enable_power_law_2
        data = load(sprintf('dat/statistic.power2.%s', network))
        suffix = 'y'; 
    elseif enable_power_law_3
        data = load(sprintf('dat/statistic.power3.%s', network))
        suffix = '3'; 
    end

    if enable_power_law
        if info.format == consts.SYM
            power = [ data(1) ]; 
        else
            power = [ data(1) data(3) data(5) ] 
        end
    elseif enable_power_law_2 | enable_power_law_3
        if info.format == consts.SYM
            power = [ data(1) ]; 
        else
            c = floor((length(data) - 1) / 3)
            power = [ data(1) data(1 + c) data(1 + c + c) ] 
        end
    end

    if enable_power_law_2 | enable_power_law_3
        if info.format == consts.SYM
            xmin = [ data(2) ];       
        else
            xmin = [ data(2) data(2+c) data(2 + c + c) ]; 
        end
    end

    if enable_power_law_3
        if info.format == consts.SYM
            pvalue = [ data(4) ];       
        else
            pvalue = [ data(4) data(4+c) data(4 + c + c) ]; 
        end
    end

else
    enable_power_law_any = 0; 
    if info.format == consts.SYM
        power = [ NaN ];
    else
        power = [ NaN NaN NaN ]; 
    end
    suffix = ''; 
end

%
% Mean vs stddev of ratings
% 
if info.weights == consts.WEIGHTED | info.weights == consts.SIGNED

    sums_u = full(sum(A,2)); 
    counts_u = full(sum(A~=0, 2)); 
    means_u = sums_u ./ counts_u; 		
    sqsums_u = full(sum(A .^ 2,2)); 
    asqsums_u = counts_u .* (means_u .^ 2) + sqsums_u - 2 * (means_u .* sums_u); 
    std_u = (asqsums_u ./ (counts_u-1)) .^ .5; 

    sums_v = full(sum(A,1)); 
    counts_v = full(sum(A~=0, 1)); 
    means_v = sums_v ./ counts_v; 		
    sqsums_v = full(sum(A .^ 2,1)); 
    asqsums_v = counts_v .* (means_v .^ 2) + sqsums_v - 2 * (means_v .* sums_v); 
    std_v = (asqsums_v ./ (counts_v-1)) .^ .5; 
    
    plot(means_u, std_u, '.', 'Color', [.9 .5 0]); 
    xlabel('Mean rating (\mu)', 'FontSize', font_size);
    ylabel('Standard deviation of ratings', 'FontSize', font_size); 
    set(gca, 'FontSize', font_size); 
    konect_print(sprintf('plot/degree.ms.u.%s.eps', network)); 

    plot(means_v, std_v, '.', 'Color', [.9 .5 0]); 
    xlabel('Mean rating (\mu)', 'FontSize', font_size);
    ylabel('Standard deviation of ratings', 'FontSize', font_size); 
    set(gca, 'FontSize', font_size); 
    konect_print(sprintf('plot/degree.ms.v.%s.eps', network)); 

end

%
% Degree distribution
%

fprintf(1, 'Degree distribution...\n'); 

if info.weights == consts.SIGNED | info.weights == consts.WEIGHTED | ...
        info.weights == consts.MULTIWEIGHTED | info.weights == consts.POSWEIGHTED
    A_x = A ~= 0; 
else
    A_x = A; 
end

if info.format == consts.SYM

    degree_print(A_x + A_x', power(1), xmin(1), pvalue(1), 'Degree (d)', 'a');
    konect_print(sprintf('plot/degree.a%s.%s.eps', suffix, network)); 

elseif info.format == consts.ASYM

    degree_print(A_x + A_x', power(1), xmin(1), pvalue(1), 'Degree (d)', 'a');
    konect_print(sprintf('plot/degree.a%s.%s.eps', suffix, network)); 
    degree_print(A_x, power(2), xmin(2), pvalue(2), 'Outdegree (d^+)', 'u');
    konect_print(sprintf('plot/degree.u%s.%s.eps', suffix, network)); 
    degree_print(A_x', power(3), xmin(3), pvalue(3), 'Indegree (d^-)', 'v');
    konect_print(sprintf('plot/degree.v%s.%s.eps', suffix, network)); 

elseif info.format == consts.BIP

    degree_print([ sparse(n1,n1) A_x ; A_x' sparse(n2,n2) ], power(1), xmin(1), pvalue(1), 'Degree (d)', 'a');
    konect_print(sprintf('plot/degree.a%s.%s.eps', suffix, network)); 
    degree_print(A_x, power(2), xmin(2), pvalue(2), 'Degree (d)', 'u');
    konect_print(sprintf('plot/degree.u%s.%s.eps', suffix, network)); 
    degree_print(A_x', power(3), xmin(3), pvalue(3), 'Degree (d)', 'v');
    konect_print(sprintf('plot/degree.v%s.%s.eps', suffix, network)); 

end
