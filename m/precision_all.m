%
% Plot the precision over a given set of methods.
%
% PARAMETERS 
%	$NETWORK
%	$METHODS	Space-separated list of methods
%
% INPUT 
%	dat/precision.$METHOD.$NETWORK.mat	for each $METHOD in $METHODS
%
% OUTPUT 
%	plot/precision.all.[a].$MEASURE.$NETWORK.eps
%		for all $MEASURE
%		a - Show only the best submethod for each method
%		b - Show all submethods for all methods
%

network = getenv('NETWORK');
methods = getenv('METHODS'); 

methods = regexp(methods, '\S+', 'match'); methods = methods';

labels_measure = get_labels_measure(); 

measures = fieldnames(labels_measure)

for i = 1 : length(measures) 

    measure = measures{i}

    methods_used = []; 
    submethods = []; 
    precisions = []; 

    methodsx = []; 
    submethodsx = [];
    precisionsx = []; 

    for k = 1 : length(methods)
        method = methods{k}

        precision = load(sprintf('dat/precision.%s.%s.mat', method, network))

        submethods_method = fieldnames(precision.precisions)

        if length(submethods_method) > 0

            precision_best = -Inf 

            for l = 1 : length(submethods_method)
                submethod = submethods_method{l}
                precision_submethod = precision.precisions.(submethod).(measure)(1)
                if precision_submethod > precision_best
                    precision_best = precision_submethod; 
                    submethod_best = submethod; 
                end

                methodsx = [ methodsx ; cellstr(method) ]; 
                submethodsx = [ submethodsx ; cellstr(submethod) ]; 
                precisionsx = [ precisionsx ; precision_submethod ]; 
            end

            methods_used = [ methods_used ; cellstr(method) ]; 
            submethods = [ submethods ; cellstr(submethod_best) ]; 
            precisions = [ precisions ;  precision_best ]; 
        end
    end

    [~,ii] = sort(-precisions); 
    precisions_plot(methods_used(ii), submethods(ii), precisions(ii), measure); 
    konect_print(sprintf('plot/precision.all.a.%s.%s.eps', measure, network)); 

    [~,ii] = sort(-precisionsx);
    nn = min(length(precisionsx), 40); 
    ii = ii(1:nn); 
    precisions_plot(methodsx(ii), submethodsx(ii), precisionsx(ii), measure); 
    konect_print(sprintf('plot/precision.all.b.%s.%s.eps', measure, network)); 
end
