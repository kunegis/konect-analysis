%
% Colors used for drawing various graphs consistently. 
%
% RESULT
%	colors			Struct by submethod
%		.(submethod)	(1*3) Color
%	line_styles		Struct by submethod
%		.(submethod)	(string) line style
%	markers			Struct by submethod
%		.(submethod)	(string) marker 
%

function [colors line_styles markers] = styles_submethod()

colors = struct(); 
line_styles = struct(); 
markers = struct(); 

% Local 
colors.main		= [0  0  .8];	line_styles.main	= '-.';	markers.main		= 's'; 
colors.zero      	= [0  1  0 ];   line_styles.zero      	= ''  ; markers.zero      	= '+'; 
colors.meane     	= [0  0  1 ];   line_styles.meane     	= ''  ; markers.meane     	= 's'; 
colors.rank1     	= [0  .5 0 ];  line_styles.rank1     = ''  ; markers.rank1     = 's'; 
colors.rank2     	= [0  .7 0 ];  line_styles.rank2     = ''  ; markers.rank2     = 's'; 
colors.meanu     	= [0  0  .5];  line_styles.meanu     = ''  ; markers.meanu     = '*'; 
colors.meanv     	= [.5 0  .5];  line_styles.meanv     = ''  ; markers.meanv     = 'o'; 
colors.meanuv    	= [0  .5 .5];  line_styles.meanuv    = ''  ; markers.meanuv    = '+'; 
colors.meaneuv   	= [.5 .5 .5];  line_styles.meaneuv   = ''  ; markers.meaneuv   = 's'; 
colors.regr      	= [.5 .5 .5];  line_styles.regr      = ''  ; markers.regr      = 'd'; 
colors.regrn     	= [.6 .6 .6];  line_styles.regrn     = ''  ; markers.regrn     = 'x'; 
colors.mask1     	= [.7 0  0 ];  line_styles.mask1     = ''  ; markers.mask1     = '*'; 
colors.half      	= [0  .7 0 ];  line_styles.half      = ''  ; markers.half      = 'o'; 
colors.all       	= [0  0  .7];  line_styles.all       = ''  ; markers.all       = '+'; 

% Local:  Neighborhood methods
colors.common		= [1  0  0 ];	line_styles.common	= '';	markers.common		= 'x'; 
colors.abscommon	= [1  0  0 ];	line_styles.abscommon	= '';	markers.abscommon	= 'x'; 
colors.cosine		= [.65 0 0 ];	line_styles.cosine	= '';	markers.cosine		= 'x'; 
colors.abscosine	= [.65 0 0 ];	line_styles.abscosine	= '';	markers.abscosine	= 'x'; 
colors.lhni		= [.65 0 0 ];	line_styles.lhni	= '';	markers.lhni		= 'x'; 
colors.ra		= [.65 0 0 ];	line_styles.ra		= '';	markers.ra		= 'x'; 
colors.sorensen		= [0  0  .6];	line_styles.sorensen	= '--';	markers.sorensen	= '*'; 
colors.hpi		= [.9 .9 .9];	line_styles.hpi		= '';	markers.hpi		= '*'; 
colors.hdi		= [.6 .6 .6];	line_styles.hdi		= '';	markers.hdi		= '*'; 
colors.jaccard		= [0  0  0 ];	line_styles.jaccard	= ''  ;	markers.jaccard		= 'o'; 
colors.absjaccard	= [0  0  0 ];	line_styles.absjaccard	= ''  ;	markers.absjaccard		= 'o'; 
colors.neib      	= [1  0  1 ];   line_styles.neib      	= ''  ; markers.neib      	= '*';
colors.pref      	= [.7 .7 .7];   line_styles.pref      	= ''  ; markers.pref      	= 'o'; 
colors.adad      	= [.4 .4 .4];   line_styles.adad      	= ''  ; markers.adad      	= '+'; 
colors.absadad      	= [.4 .4 .4];   line_styles.absadad      	= ''  ; markers.absadad      	= '+'; 
colors.path3       	= [.7 0  1 ];	line_styles.path3	= '-';  markers.path3       	= '+';

colors.commonasym	= [1  0  0 ];	line_styles.commonasym  = '';	markers.commonasym	= 'x'; 
colors.cosineasym	= [.65 0 0 ];	line_styles.cosineasym	= '';	markers.cosineasym	= 'x'; 
colors.lhniasym		= [.65 0 0 ];	line_styles.lhniasym	= '';	markers.lhniasym	= 'x'; 
colors.raasym		= [.65 0 0 ];	line_styles.raasym	= '';	markers.raasym		= 'x'; 
colors.sorensenasym	= [0  0  .6];	line_styles.sorensenasym= '--';	markers.sorensenasym	= '*'; 
colors.hpiasym		= [.9 .9 .9];	line_styles.hpiasym	= '';	markers.hpiasym		= '*'; 
colors.hdiasym		= [.6 .6 .6];	line_styles.hdiasym	= '';	markers.hdiasym		= '*'; 
colors.jaccardasym	= [0  0  0 ];	line_styles.jaccardasym	= ''  ;	markers.jaccardasym	= 'o'; 
colors.neibasym      	= [1  0  1 ];   line_styles.neibasym   	= ''  ; markers.neibasym      	= '*';
colors.prefasym      	= [.7 .7 .7];   line_styles.prefasym   	= ''  ; markers.prefasym      	= 'o'; 
colors.adadasym      	= [.4 .4 .4];   line_styles.adadasym   	= ''  ; markers.adadasym      	= '+'; 

colors.commonout	= [1  0  0 ];	line_styles.commonout  	= '';	markers.commonout	= 'x'; 
colors.cosineout	= [.65 0 0 ];	line_styles.cosineout	= '';	markers.cosineout	= 'x'; 
colors.lhniout		= [.65 0 0 ];	line_styles.lhniout	= '';	markers.lhniout	= 'x'; 
colors.raout		= [.65 0 0 ];	line_styles.raout	= '';	markers.raout		= 'x'; 
colors.sorensenout	= [0  0  .6];	line_styles.sorensenout= '--';	markers.sorensenout	= '*'; 
colors.hpiout		= [.9 .9 .9];	line_styles.hpiout	= '';	markers.hpiout		= '*'; 
colors.hdiout		= [.6 .6 .6];	line_styles.hdiout	= '';	markers.hdiout		= '*'; 
colors.jaccardout	= [0  0  0 ];	line_styles.jaccardout	= ''  ;	markers.jaccardout	= 'o'; 
colors.neibout      	= [1  0  1 ];   line_styles.neibout   	= ''  ; markers.neibout      	= '*';
colors.prefout      	= [.7 .7 .7];   line_styles.prefout   	= ''  ; markers.prefout      	= 'o'; 
colors.adadout      	= [.4 .4 .4];   line_styles.adadout   	= ''  ; markers.adadout      	= '+'; 

colors.commonin		= [1  0  0 ];	line_styles.commonin	= '';	markers.commonin	= 'x'; 
colors.cosinein		= [.65 0 0 ];	line_styles.cosinein	= '';	markers.cosinein	= 'x'; 
colors.lhniin		= [.65 0 0 ];	line_styles.lhniin	= '';	markers.lhniin		= 'x'; 
colors.rain		= [.65 0 0 ];	line_styles.rain	= '';	markers.rain		= 'x'; 
colors.sorensenin	= [0  0  .6];	line_styles.sorensenin= '--';	markers.sorensenin	= '*'; 
colors.hpiin		= [.9 .9 .9];	line_styles.hpiin	= '';	markers.hpiin		= '*'; 
colors.hdiin		= [.6 .6 .6];	line_styles.hdiin	= '';	markers.hdiin		= '*'; 
colors.jaccardin	= [0  0  0 ];	line_styles.jaccardin	= ''  ;	markers.jaccardin	= 'o'; 
colors.neibin      	= [1  0  1 ];   line_styles.neibin   	= ''  ; markers.neibin      	= '*';
colors.prefin      	= [.7 .7 .7];   line_styles.prefin   	= ''  ; markers.prefin      	= 'o'; 
colors.adadin      	= [.4 .4 .4];   line_styles.adadin   	= ''  ; markers.adadin      	= '+'; 

% Meta
colors.perf		= [0  0  0 ];	line_styles.perf	= ':';	markers.perf      	= 'o'; 
colors.id		= [0  0  1 ];	line_styles.id		= '-';	markers.id		= '+'; 
colors.like		= [0  0  .7];	line_styles.like	= '--';	markers.like		= '+'; 
colors.lin		= [.7 0  0 ];	line_styles.lin		= ':';	markers.lin		= 'o';
colors.euclidean	= [0  .6 .2];	line_styles.euclidean	= '--';	markers.euclidean	= '*'; 
colors.sne		= [1 0 0];	line_styles.sne		= '--';	markers.sne		= '*';
colors.rank1		= [1  0  0 ];	line_styles.rank1	= '-';	markers.rank1		= 's'; 
colors.rank2		= [1  0  0 ];	line_styles.rank2	= '-';	markers.rank2		= 's'; 
colors.rank3		= [1  0  0 ];	line_styles.rank3	= '-';	markers.rank3		= 's'; 
colors.rank1i		= [1  0  0 ];	line_styles.rank1i	= '-';	markers.rank1i		= 's'; 
colors.rank2i		= [1  0  0 ];	line_styles.rank2i	= '-';	markers.rank2i		= 's'; 
colors.rank3i		= [1  0  0 ];	line_styles.rank3i	= '-';	markers.rank3i		= 's'; 

% Polynomials
colors.poly		= [1  0  0 ];	line_styles.poly	= '-';	markers.poly		= 's'; 
colors.polyo		= [1  0  0 ];	line_styles.polyo	= '--';	markers.polyo		= 's'; 
colors.polyn		= [1  .8 0 ];	line_styles.polyn	= '--';	markers.polyn		= '+';
colors.polyon		= [1  .8 0 ];	line_styles.polyon	= ':';	markers.polyon		= '+';
colors.polyl		= [.7  .7  0];	line_styles.polyl	= '--';	markers.polyl		= 'o';
colors.polynl		= [1 .5  .5];	line_styles.polynl	= '--';	markers.polynl		= 's';
colors.polyx		= [1  0  0 ];	line_styles.polyx	= '-';	markers.polyx		= 's'; 

% Other
colors.rr		= [0  1   1];	line_styles.rr		= '-';	markers.rr		= 'o'; 
colors.rrs		= [0 .8  .8];	line_styles.rrs		= '-';	markers.rrs		= '*'; 
colors.rrl		= [0  1  0 ];	line_styles.rrl		= '-';	markers.rrl		= 'o';
colors.exp		= [1  0  1 ];	line_styles.exp		= '-';	markers.exp		= '+'; 
colors.expo		= [.7 0  1 ];	line_styles.expo	= '--';	markers.expo		= '*';
colors.expl		= [.7  0  1];	line_styles.expl	= '-';  markers.expl		= '+'; 
colors.expnl		= [0  0   1];	line_styles.expnl	= '--';	markers.expnl		= 'o'; 
colors.rat		= [.7  1 .7];	line_styles.rat		= '-';	markers.rat		= 'o';
colors.rato		= [.3 .7  1];	line_styles.rato	= '--';	markers.rato		= '*';
colors.ratn		= [.7  1 .7];	line_styles.ratn	= ':';	markers.ratn		= 'o';
colors.ratno		= [.3 .7  1];	line_styles.ratno	= '-.';	markers.ratno		= '*';
colors.ratl		= [.9  1 .3];	line_styles.ratl	= '-';	markers.ratl		= 's'; 
colors.uni		= [.7 .7 0 ];	line_styles.uni		= '-';	markers.uni		= '+';
colors.lap		= [0  .5 0 ];	line_styles.lap		= '-';	markers.lap		= 's'; 

%
% Available styles 
%

%% colors.sinh_sym       = [.7 0  1 ];  line_styles.sinh_sym	= '-';  markers.sinh_sym       = '+';
%% colors.sinh_asym      = [1 .7  0 ];  line_styles.sinh_asym	= '-';  markers.sinh_asym      = 'o';
%% colors.sinh_back      = [0  1 .7 ];  line_styles.sinh_back	= '-';  markers.sinh_back      = '*';
%% colors.sinh_bip       = [1  0  0 ];  line_styles.sinh_bip	= '-';  markers.sinh_bip       = '+';
%% colors.exp_sym        = [.9 .2  1 ];  line_styles.exp_sym	= '-';  markers.exp_sym        = '+';
%% colors.exp_asym       = [.7 0  1 ];  line_styles.exp_asym	= '-';  markers.exp_asym       = 'o';
%% colors.exp_back       = [.7 0  1 ];  line_styles.exp_back	= '-';  markers.exp_back       = '*';
%% colors.exp_bip        = [.7 0  1 ];  line_styles.exp_bip	= '-';  markers.exp_bip        = '+';
%% colors.neu_sym        = [0  1  0 ];  line_styles.neu_sym	= '-';  markers.neu_sym       = 'o';
%% colors.neu_asym       = [0  1  0 ];  line_styles.neu_asym	= '-';  markers.neu_asym       = 'o';
%% colors.neu_back       = [0  1  0 ];  line_styles.neu_back	= '-';  markers.neu_back       = 'o';
%% colors.neu_bip        = [0  1  0 ];  line_styles.neu_bip	= '-';  markers.neu_bip       = 'o';
%% colors.neuodd_sym     = [1 0 0];  line_styles.neuodd_sym	= '-.'; markers.neuodd_sym     = '+';
%% colors.neuodd_asym    = [0  1  .3];  line_styles.neuodd_asym	= '-.'; markers.neuodd_asym    = 'o';
%% colors.neuodd_back    = [0  1  .3];  line_styles.neuodd_back	= '-.'; markers.neuodd_back    = '*';
%% colors.neuodd_bip     = [.9 1  .9];  line_styles.neuodd_bip	= '-.'; markers.neuodd_bip     = '+';
%% colors.dim_lin_sym    = [0  1   1];  line_styles.dim_lin_sym	= '-';  markers.dim_lin_sym   = 'o'; 
%% colors.dim_lin_asym   = [0  1   1];  line_styles.dim_lin_asym	= '-';  markers.dim_lin_asym   = 'o'; 
%% colors.dim_lin_back   = [0  1   1];  line_styles.dim_lin_back	= '-';  markers.dim_lin_back   = 'o'; 
%% colors.dim_lin_bip    = [0  1   1];  line_styles.dim_lin_bip	= '-';  markers.dim_lin_bip   = 'o'; 
%% colors.rat_sym        = [.5 1  .5];  line_styles.rat_sym	= '-';  markers.rat_sym       = 'o';
%% colors.rat_asym       = [0  1  0 ];  line_styles.rat_asym	= '-';  markers.rat_asym       = 'o';
%% colors.rat_back       = [0  1  0 ];  line_styles.rat_back	= '-';  markers.rat_back       = 'o';
%% colors.rat_bip        = [0  1  0 ];  line_styles.rat_bip	= '-';  markers.rat_bip       = 'o';
%% colors.lap_sym        = [0  .6 0 ];  line_styles.lap_sym	= '-';  markers.lap_sym       = 's'; 

%% colors.sne_abs_sym    = [.9 .9 .9];  line_styles.sne_abs_sym  = '';   markers.sne_abs_sym    = '+'; 
%% colors.sne_abs_asym   = [.9 .9 .9];  line_styles.sne_abs_asym = '';   markers.sne_abs_asym   = 'o'; 
%% colors.sne_abs_back   = [.9 .9 .9];  line_styles.sne_abs_back = '';   markers.sne_abs_back   = '*'; 
%% colors.sne_abs_bip    = [.9 .9 .9];  line_styles.sne_abs_bip  = '';   markers.sne_abs_bip    = '+'; 
%% colors.sne_squ_sym    = [.6 .6 .6];  line_styles.sne_squ_sym  = '';   markers.sne_squ_sym    = '+'; 
%% colors.sne_squ_asym   = [.6 .6 .6];  line_styles.sne_squ_asym = '';   markers.sne_squ_asym   = 'o'; 
%% colors.sne_squ_back   = [.6 .6 .6];  line_styles.sne_squ_back = '';   markers.sne_squ_back   = '*'; 
%% colors.sne_squ_bip    = [.6 .6 .6];  line_styles.sne_squ_bip  = '';   markers.sne_squ_bip    = '+'; 

