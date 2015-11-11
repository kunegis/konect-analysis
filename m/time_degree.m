%
% Draw overlay of degree distributions over time. 
%
% PARAMETERS 
%	$NETWORK
%	$RANDOMIZE	'1' to randomize order of edges 
%
% INPUT 
%	dat/split.$NETWORK.mat
%
% OUTPUT 
%	plot/time_degree.$NETWORK.eps
%

consts = konect_consts(); 

network = getenv('NETWORK'); 
randomize = getenv('RANDOMIZE'); 
randomize = strcmp(randomize, '1'); 

info = read_info(network); 

split = load(sprintf('dat/split.%s.mat', network)); 

T = [split.T_source; split.T_target; split.T_test]; 

s = size(T,1)

if randomize
    p = randperm(s);
    T(p, :); 
end

steps = [round(s/3), round(s * 2/3), s]

cm = ...
    [232  43 235;
     35  76 191;
     67 177  58] / 255;		     

point_styles = [cellstr('o'), cellstr('x'), cellstr('s')]; 
		     
hold on; 

for i = 1 : prod(size(steps))

    A = konect_spconvert(T(1:steps(i), :), split.n1, split.n2); 

    if info.format == consts.SYM
        A = A + A'; 
    end  

    degree = full(sum(A,2));
    [counts, ids] = sort(degree);
    maxcount = counts(end-0);  
    freq = histc(counts, 0:maxcount);

    nz = freq ~= 0; 
    ra = 0:maxcount; 
    ra = ra(nz);
    fq = freq(nz); 

    point_style = point_styles(i); 
    point_style = point_style{:};

    loglog(ra, fq, point_style, 'Color', cm(i,:));
end

xlabel('Number of neighbors (n)');
ylabel('Frequency'); 

set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');

legend([cellstr('|E| = 1/3 |Eall|'), cellstr('|E| = 2/3 |Eall|'), cellstr('|E| = 3/3 |Eall|')]); 

extra = '';
if randomize
    extra = '.rand'; 
end
	      	   
konect_print(sprintf('plot/time_degree.%s%s.eps', network, extra));  

