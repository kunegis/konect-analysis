%
% Labels for combined method/submethods.
%
% RESULT 
%	labels
%	.([method "." submethod])	Readable label of the
%	method/submethod combination 
%

function labels = get_labels_method_submethod()

labels = struct();

labels.sym_expo		= 'SINH';
labels.sym_rato		= 'NEU';
labels.sym_polyo	= 'POLY';
labels.sym_polyon	= 'POLYN';

labels.sym_n_polyo	= 'N-POLY';
labels.sym_n_polyon	= 'N-POLYN';
labels.sym_n_expo	= 'N-HEAT';
labels.sym_n_ratno	= 'N-NEU';

labels.lap_lap		= 'COM';
labels.lap_expl		= 'HEAT';

labels.pref_main	= 'PA';

labels.neib3_path3	= 'P3'; 
