%
% Labels of submethods. 
% 
% RESULT 
%	labels
%		.(submethod)	Readable label of the submethod
%

function labels = get_labels_submethod()

labels = struct(); 

% Local
labels.adad = 		'AA';
labels.absadad = 	'|AA|';
labels.jaccard = 	'Jaccard';
labels.absjaccard = 	'|Jaccard|';
labels.common = 	'CN'; 
labels.abscommon = 	'|CN|';
labels.cosine = 	'cos'; 
labels.abscosine = 	'|cos|'; 
labels.ra = 		'RA'; 
labels.lhni = 		'LHN1';
labels.sorensen =	'Sorensen';
labels.hpi =		'HPI';
labels.hdi =		'HDI';
labels.path3 =		'Path3'; 

labels.adadasym = 	'AA asym';
labels.jaccardasym = 	'Jaccard asym';
labels.commonasym = 	'CN asym'; 
labels.cosineasym = 	'cos asym'; 
labels.raasym = 	'RA asym'; 
labels.lhniasym = 	'LHN1 asym';
labels.sorensenasym =	'Sorensen asym';
labels.hpiasym =	'HPI asym';
labels.hdiasym =	'HDI asym';

labels.adadout = 	'AA out';
labels.jaccardout = 	'Jaccard out';
labels.commonout = 	'CN out'; 
labels.cosineout = 	'cos out'; 
labels.raout = 		'RA out'; 
labels.lhniout = 	'LHN1 out';
labels.sorensenout =	'Sorensen out';
labels.hpiout =		'HPI out';
labels.hdiout =		'HDI out';

labels.adadin = 	'AA in';
labels.jaccardin = 	'Jaccard in';
labels.commonin = 	'CN in'; 
labels.cosinein = 	'cos in'; 
labels.rain = 		'RA in'; 
labels.lhniin = 	'LHN1 in';
labels.sorensenin =	'Sorensen in';
labels.hpiin =		'HPI in';
labels.hdiin =		'HDI in';

% Extra spectral
labels.like = 		'LIKE'; 
labels.main = 		''; 
labels.euclidean = 	'Eucl.'; 
labels.sne = 		'Extra.';
labels.rank1 = 		'Rank 1';
labels.rank2 = 		'Rank 2'; 
labels.rank3 = 		'Rank 3'; 
labels.rank1i = 	'Rank 1 I';
labels.rank2i = 	'Rank 2 I'; 
labels.rank3i = 	'Rank 3 I'; 

% Curves
labels.lin = 		'ax'; 
labels.exp = 		'exp(ax)'; 
labels.expo = 		'sinh(ax)'; 
labels.expl = 		'exp(-ax)'; 
labels.expnl = 		'exp(-a(1-x))'; 
labels.poly = 		'P(x)';
labels.polyn = 		'P_n(x)'; 
labels.polyo = 		'P_o(x)';
labels.polyon = 	'P_{on}(x)';
labels.uni = 		'uni(x)'; 
labels.polyl = 		'P(1/x)'; 
labels.polynl = 	'P_n(1/x)'; 
labels.rat = 		'1/(1-ax)'; 
labels.rato = 		'x/(1-ax^2)'; 
labels.ratl = 		'1/(1+ax)'; 
labels.ratn = 		'1/(1-x)'; 
labels.ratno = 		'x/(1-x^2)'; 
labels.rr = 		'x >= \lambda_r'; 
labels.rrs = 		'|x| >= |\lambda_r|'; 
labels.rrl = 		'x >= \lambda_r'; 
labels.lap = 		'1/x';
labels.polyx = 		'P(X)'; 
