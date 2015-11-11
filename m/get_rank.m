%
% Compute the dimensional parameter r in function of dataset.  
% 
% RESULT 
% 	r_svd 	reduced rank for singular value decomposition
% 	r_lap 	reduced rank for Laplacian decomposition
%
% PARAMETERS 
%	network	Dataset name
%
% INPUT 
% 	dat/runtime
%

function [r, r_l] = get_rank(network)

alpha = 0.7;  % Scaling factor for automated computation
r_min = 30;  
r_min_l = r_min;
lap_proportion = 0.5; 

info = read_info(network); 

n1 = info.n1; 
n2 = info.n2; 
m_ = info.lines; 

r_max = min(n1,n2); % Rank must not be larger than dimensions of matrix 

rs = struct();


%
% List of predefined sizes
%
rs.advogato = 		 		[500  75];
rs.arenas_meta = 			[150  75]; 
rs.citeseer = 		 		[ 75  38]; 
rs.contact = 		 		[  5   5]; 
rs.movielens_100k__rating = 	 	[ 60  30]; 
rs.movielens_100k__rating_unweighted = 	[100  50]; 
rs.movielens_1m =           		[100  50]; 
rs.www = 		 		[ 75  38]; 
rs.epinions = 		 		[ 70  35]; 
rs.slashdot_zoo =  	 		[ 90  75]; 
rs.hep_th_citations =    		[ 75  38]; 
rs.facebook_wosn_links = 		[ 70  35];
rs.facebook_wosn_wall =  		[ 49  15];
rs.filmtipset =          		[  9   9]; 
rs.trec_wt10g =          		[  9   9]; 
rs.wiki_Talk =           		[  9   9]; 
rs.roadNet_CA = 			[ 15  15]; 
rs.dbpedia_similar = 			[100 100]; 
rs.edit_frwikibooks = 			[ 40  20]; 
rs.gottron_net_core = 			[100  50]; 
rs.dblp_cite = 				[400  50]; 
rs.elec = 				[1000 1000]; % This is used in examples plots in the handbook 
rs.web_Stanford = 			[120  60];
rs.wikisigned_k2 = 			[120  60];  

fieldname = network; 
fieldname = regexprep(fieldname, '_', '__'); 
fieldname = regexprep(fieldname, '-', '_');

if isfield(rs, fieldname)

  rs_network = rs.(fieldname);
  r = rs_network(1);
  r_l = rs_network(2); 

else % Automatic settings

  x = load('dat/runtime');

  r = round(alpha * exp(-x(1)) * (n1 + n2)^-x(2) * m_^-x(3) * (n1*n2)^-x(4)); 

  r_l = round(lap_proportion * r);

  % Lower bounds
  if (r < r_min), r = r_min; end;
  if (r_l < r_min_l), r_l = r_min_l; end;

  % Upper bounds
  if r   > r_max, r   = r_max; end
  if r_l > r_max, r_l = r_max; end

  r
  r_l 
end


