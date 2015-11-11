%
% Plot precisions for one network/method combination.
%
% PARAMETERS 
%	$NETWORK
%	$METHOD
%
% INPUT 
%	dat/precision.$METHOD.$NETWORK.mat
%
% OUTPUT 
%	plot/precision.one.[a].$MEASURE.$METHOD.$NETWORK.eps
%		for all $MEASURE
%

network = getenv('NETWORK');
method = getenv('METHOD'); 

precision = load(sprintf('dat/precision.%s.%s.mat', method, network)); 

labels_measure = get_labels_measure(); 

measures = fieldnames(labels_measure)

for i = 1 : length(measures) 

    measure = measures{i}

    names = [];
    precisions = []; 

    submethods = fieldnames(precision.precisions);
    for k = 1 : length(submethods)
        submethod = submethods{k}
        values = precision.precisions.(submethod).(measure)
        precisions = [ precisions ; values(1) ]; 
    end

    precisions_plot([], submethods, precisions, measure); 
    konect_print(sprintf('plot/precision.one.a.%s.%s.%s.eps', measure, method, network)); 

end
