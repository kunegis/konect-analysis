%
% The label associated with a measure.  The content of the returned
% struct is used in various places as the canonical list of measures to
% use. 
%
% RESULT 
%	labels		Struct of labels by measure name
%	labels_short	Short names 
%

function [labels labels_short] = get_labels_measure()

labels = struct(); 

% Individual ones can be enabled/disabled, but CORR must always be
% enabled, because we use it as a target in the makefile. 

%labels.ap	= 'Average precision';
%labels.map	= 'Mean average precision'; 
labels.corr	= 'Pearson correlation';
%labels.spear	= 'Spearman correlation';
labels.auc	= 'Area under the curve';
%labels.mauc	= 'Mean area under the curve';

% KENDALL is not computed because it is too slow. 
% MAP and MAUC removed because they are slow and the results are indistinguishible from AP and AUC. 


labels_short = struct();

labels_short.corr = '\rho';
labels_short.auc = 'AUC'; 
