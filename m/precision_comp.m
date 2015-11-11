%
% Compute precision of predictions. 
%
% PARAMETERS 
%	$NETWORK
%	$METHOD
%
% INPUT 
%	dat/prediction.$METHOD.$NETWORK.mat
%	dat/split.$NETWORK.mat 
%	dat/meanst.$NETWORK.mat
%
% OUTPUT 
%	dat/precision.$METHOD.$NETWORK.mat
%		precisions{submethod}	Precisions by submethod; each entry is a 2-vector of the value and the runtime in seconds
%			.$MEASURE	e.g., "auc"
%

labels_measure = get_labels_measure(); 
measure_names = fieldnames(labels_measure); 

network = getenv('NETWORK');
method = getenv('METHOD'); 

split = load(sprintf('dat/split.%s.mat', network)); 
prediction = load(sprintf('dat/prediction.%s.%s.mat', method, network)); 

if length(split.T_test_zero)
    if size(split.T_test,2) == 3
        T_all = [ split.T_test ; split.T_test_zero, zeros(size(split.T_test_zero, 1), 1) ]; 
    else
        T_all = [ split.T_test, ones(size(split.T_test, 1), 1) ; split.T_test_zero, zeros(size(split.T_test_zero, 1), 1) ]; 
    end
else
    T_all = [ split.T_test ]; 
end

meanst = load(sprintf('dat/meanst.%s.mat', network)); 

T_all = konect_normalize_additively(T_all, meanst); 			  

precisions = struct(); 

submethods = fieldnames(prediction.predictions);

for i = 1 : length(submethods)

    submethod = submethods{i};
    fprintf(1, '\nsubmethod = %s\n', submethod); 
    prediction_submethod = prediction.predictions.(submethod); 
    p_normal = prediction_submethod.prediction;
    p_zero = prediction_submethod.prediction_zero; 

    if length(split.T_test_zero) 
        p = [ p_normal ; p_zero ]; 
    else
        p = [ p_normal ]; 
    end  

    p = real(p); 

    for i = 1:length(measure_names)
        measure = measure_names{i}; 
        fprintf(1, '%s(%s) = ', submethod, measure); 
        t0 = cputime; 
        value = measure_compute(measure, p, T_all)
        t1 = cputime;
        runtime = t1 - t0; 
        fprintf(1, '%f [%f s]\n', value, runtime); 

        if ~isfinite(value)
            error('*** Non-finite precision value'); 
        end
        precisions.(submethod).(measure) = [ value runtime ]; 
    end

end

save(sprintf('dat/precision.%s.%s.mat', method, network), '-v7.3', 'precisions'); 
