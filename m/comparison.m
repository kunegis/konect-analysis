%
% Comparison plot of all link prediction methods. 
%
% Important:  the (a) and (b) plots are not fair since they take, for
% each network, a separate best submethod for each method, meaning
% that a method with many submethods will seem to perform better than
% a method with few submethods. 
%
% PARAMETERS 
%	$NETWORKS	Space-separated list of networks
%	$METHODS	Space-separated list of methods; may contain
%			simple method (in which case all submethods
%			are shown), or a string of the form
%			"$METHOD.$SUBMETHOD", in which case only the
%			given submethods are shown 
% 	$NAME		Used in output filename
%
% INPUT 
%	dat/precision.$METHOD.$NETWORK.mat
%		for each $METHOD in $METHODS
%		for each $NETWORK in $NETWORKS
%
% OUTPUT 
%	plot/comparison.{a,b,ax,bx}{,-bw}.$MEASURE.$NAME.eps
%		for all $MEASURE's
%		(a) - Pairwise statistical significance matrix (by method)
%		(b) - Method by network plot (by method)
%		(ax) - All, i.e. all submethods
%		(bx) - All, i.e. all submethods
%		(legend,legendx) - The legend for the (a) and (ax)
%		plots 
%		(-bw) - Black and white version of the plots 
%

networks = getenv('NETWORKS');
methods_compound = getenv('METHODS'); 
name = getenv('NAME'); 

networks = regexp(networks, '\S+', 'match'); networks = networks'

assert (length(networks) > 0); 

methods_compound = regexp(methods_compound, '\S+', 'match'); methods_compound = methods_compound'

% By method, a struct containing all submethods used for that
% method.  If the contained struct is empty, all submethods are
% used. 
submethods_method = struct();

for i = 1 : length(methods_compound)
    method_compound = methods_compound{i}
    if strfind(method_compound, '.')
        parts = regexp(method_compound, '[^.]+', 'match');
        method_ = parts{1}
        submethod = parts{2}
        if ~isfield(submethods_method, tofieldname(method_))
            submethods_method.(tofieldname(method_)) = struct();
        end
        submethods_method.(tofieldname(method_)).(submethod) = 1; 
    else
        submethods_method.(tofieldname(method_compound)) = struct(); 
    end
end

[labels_measure labels_short_measure] = get_labels_measure(); 
labels_submethod = get_labels_submethod();
labels_method = get_labels_method(); 
labels_method_submethod = get_labels_method_submethod(); 

measures = fieldnames(labels_measure) 

ids_submethod = get_ids_submethod();
ids_submethod_count = ids_submethod.count; 

% Struct by measure of 
%   .data (method * network)
%   .datax_global (submethod_id_global * network), with holes filled with zero
%   .datax
data_measure = struct(); 

labels_method_id = {}; 
labels_submethod_id_global = {}; 

fn = fieldnames(submethods_method)
for i = 1 : length(fn)
    fieldname_method = fn{i} 

    label_method = labels_method.(fieldname_method)
    labels_method_id(i) = cellstr(label_method); 

    for j = 1 : length(networks)
        network = networks{j};

        precision_data = load(sprintf('dat/precision.%s.%s.mat', fromfieldname(fieldname_method), network)); 

        submethods = fieldnames(precision_data.precisions); 

        for k = 1 : length(measures)
            measure = measures{k}; 

            if length(submethods) > 0

                precision_best = -Inf; 

                for l = 1 : length(submethods)
                    submethod = submethods{l}; 

                    if (0 == length(fieldnames(submethods_method.(fieldname_method)))) || ...
                           (isfield(submethods_method.(fieldname_method), submethod))

                        precision_submethod = precision_data.precisions.(submethod).(tofieldname(measure))(1); 
                        if precision_submethod > precision_best
                            precision_best = precision_submethod; 
                        end
                        submethod_id_global = (i-1) * ids_submethod_count + ids_submethod.(submethod); 
                        data_measure.(tofieldname(measure)).datax_global(submethod_id_global, j) = precision_submethod; 

                        if length(labels_submethod_id_global) < submethod_id_global | isempty(labels_submethod_id_global{submethod_id_global}) == 0

                            fieldname_method_submethod = [fieldname_method '_' submethod]; 
                            if isfield(labels_method_submethod, fieldname_method_submethod)
                                labels_submethod_id_global(submethod_id_global) = cellstr(labels_method_submethod.(fieldname_method_submethod));
                            else
                                labels_submethod_id_global(submethod_id_global) = cellstr(sprintf('%s %s', label_method, labels_submethod.(submethod))); 
                            end
                        end
                    end
                end

                value = precision_best; 

            else
                value = NaN; 
            end
    
            data_measure.(tofieldname(measure)).data(i, j) = value; 

        end
    end
end

%
% Compute DATAX to DATAX_GLOBAL
%
ids = cellfun(@(x)(~isempty(x)), labels_submethod_id_global); 

labels_submethod_id = labels_submethod_id_global(ids);

data_measure

for k = 1 : length(measures)
    measure = measures{k}; 
    data_measure.(tofieldname(measure)).datax = data_measure.(tofieldname(measure)).datax_global(ids, :); 
end

%
% Network labels
%
for j = 1 : length(networks)
    network = networks(j);
    network = network{:};

    metadata = read_meta(network); 

    name_escaped = metadata.name;
    name_escaped = regexprep(name_escaped, '–', '-'); 

    labels_network(j) = cellstr(name_escaped); 
end

%
% Colormap
%
colormap_b = load('colormap'); 
colormap_b = colormap_b(end:-1:1, :); 
colormap_b_bw = (0:.01:1)'  * [ 1 1 1 ];

%
% Plot
%
measures = fieldnames(data_measure); 
for i = 1 : length(measures)
    measure = measures{i}

    label_measure = labels_short_measure.(measure); 

    % (ax), (bx) - By submethod
    datax = data_measure.(tofieldname(measure)).datax; 

    comparison_cross(datax, ...
                     sprintf('plot/comparison.ax.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.ax-bw.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.bx.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.bx-bw.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.legendx.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.legendx-bw.%s.%s.eps', measure, name), ...
                     colormap_b, colormap_b_bw, labels_submethod_id, labels_network, label_measure); 

    % (a), (b) - By method
    data = data_measure.(tofieldname(measure)).data; 
    
    comparison_cross(data, ...
                     sprintf('plot/comparison.a.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.a-bw.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.b.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.b-bw.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.legend.%s.%s.eps', measure, name), ...
                     sprintf('plot/comparison.legend-bw.%s.%s.eps', measure, name), ...
                     colormap_b, colormap_b_bw, labels_method_id, labels_network, label_measure); 
end







