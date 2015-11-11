%
% Labels of methods and decompositions.
%
% RESULT
%	labels
%		.(method)	Label of method
%

function [labels] = get_labels_method()

labels = struct();

labels.zero 		= '0';
labels.pref 		= 'PA';
labels.mask		= 'Mask';
labels.neib		= 'Neib.'; 
labels.neib3		= 'P3';

% Decompositions
labels.sym		= 'A';
labels.sym_n 		= 'N';
labels.lap		= 'L';
labels.lapc		= 'Lc';
labels.svd		= '[0 A; A'' 0]';
labels.svd_n		= '[0 N; N'' 0]';
labels.stoch2 		= 'D^{-1}A';
labels.stoch1		= 'AD^{-1}'; 
labels.lapd		= 'L_d';
labels.lapd_n		= 'Z_d'; 
labels.back		= 'A + \alpha A'''; 
labels.diag		= 'A (asym)';
labels.diag_n		= 'N (asym)';
labels.skew		= 'A - A'''; 
labels.skewi		= 'iA - iA'''; 
labels.skewn 		= 'N - N'''; 
labels.herm		= 'A_H'; 
labels.hermi		= 'iA_H'; 
labels.hermn		= 'N_H'; 
labels.lapherm		= 'L_H'; 
labels.lapherm2		= 'L_{H2}'; 
labels.lapskew		= 'L_S'; 
labels.quantum		= 'Q'; 
labels.mskew		= 'M';
labels.lapquantum	= 'L_Q'; 
labels.lapq		= 'K'; 
labels.stochbip		= 'S'; 
labels.symabs		= '\bar A'; 
labels.symc		= 'A_c'; 

labels.quantum5         = 'Q5';
labels.quantum10        = 'Q10';
labels.quantum20        = 'Q20';
labels.quantum50        = 'Q50';
labels.quantum100       = 'Q100';
labels.quantum200       = 'Q200';
labels.quantum500       = 'Q500';
labels.quantum785       = 'Q785';
labels.quantum1000      = 'Q1000';
labels.quantum1570      = 'Q1570';


% DEDICOM
labels.dedicom1u	= 'DEDICOM 1u';
labels.dedicom1v	= 'DEDICOM 1v';
labels.dedicom2		= 'DEDICOM 2';
labels.dedicom2s	= 'DEDICOM 2s';
labels.dedicom3		= 'DEDICOM 3';
labels.dedicom3_0	= 'DEDICOM 3/0';
labels.dedicom4		= 'DEDICOM 4';
labels.takane		= 'Takane';
