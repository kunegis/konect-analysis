%
% Generate the category tabular environment.
%
% PARAMETERS 
%	$NETWORKS
%
% INPUT 
%	uni/meta.$NETWORK
%	dat/statistic.{format,weights}.$NETWORK
%
% 	for all $NETWORK in $NETWORKS
%
% OUTPUT 
%	tex/category-tabular.tex
%

networks = getenv('NETWORKS'); 

networks = regexp(networks, '[a-zA-Z0-9_-]+', 'match')
n = length(networks); 

[consts symbols_format symbols_weights] = konect_consts(); 

OUT = fopen('tex/category-tabular.tex', 'w');

if (0 > OUT)
    error('fopen'); 
end

fprintf(OUT, '\\begin{tabular}{lllllr}\n');
fprintf(OUT, '\\toprule\n');
fprintf(OUT, ['& \\textbf{Category} & \\textbf{Vertices} & \\textbf{Edges} ' ...
              '& \\textbf{Properties} & \\textbf{Count} \\\\\n']);
fprintf(OUT, '\\midrule\n');

[colors vertices edges] = konect_data_category(); 

categories= fieldnames(colors);
k = length(categories)

% Number of datasets by category
counts = struct();

% First field name is category, second field name is format or
% weights ID preceded by 'x'.  Value is always 1. 
has_format = struct();
has_weights = struct();

% Iterate over all networks
for j = 1 : n
    network = networks{j};

    meta = read_meta(network);
    category= meta.category;

    if ~isfield(colors, category) 
        fprintf(2, '*** No such category:  %s\n', category); 
        error;
    end

    if ~isfield(counts, category)
        counts.(category) = 0;
    end
    counts.(category) = counts.(category) + 1;
    
    format = load(sprintf('dat/statistic.format.%s', network));
    weights = load(sprintf('dat/statistic.weights.%s', network));

    has_format.(category).(sprintf('x%u', format)) = 1;
    has_weights.(category).(sprintf('x%u', weights)) = 1;
end

for i = 1 : k
    category= categories{i}
    fprintf(OUT, '\\textcolor{color%s}{$\\newmoon$} &', category); 
    fprintf(OUT, '%s & ', category);
    fprintf(OUT, '%s & %s & ', vertices.(category), edges.(category)); 
    for j = 1 : consts.FORMAT_COUNT
        symbol = symbols_format{j};
        if isfield(has_format.(category), sprintf('x%u', j))
            fprintf(OUT, '%s ', symbol);
        else
            fprintf(OUT, '\\phantom{%s} ', symbol);
        end
    end
    for j = 1 : consts.WEIGHTS_COUNT
        symbol = symbols_weights{j};
        if isfield(has_weights.(category), sprintf('x%u', j))
            fprintf(OUT, '%s ', symbol);
        else
            fprintf(OUT, '\\phantom{%s} ', symbol);
        end
    end
    fprintf(OUT, ' & ');
    fprintf(OUT, ' %u ', counts.(category)); 
    fprintf(OUT, '\\\\\n'); 
end

fprintf(OUT, '\\bottomrule\n');
fprintf(OUT, '\\end{tabular}\n'); 

if (0 > fclose(OUT))
    error('fclose'); 
end
