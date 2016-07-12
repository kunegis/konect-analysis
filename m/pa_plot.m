%
% Preferential attachment tests.
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/pa.$NETWORK.mat
%	dat/pa_data.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	plot/pa.[a][auv].$NETWORK.eps
%

network = getenv('network') 

consts = konect_consts(); 

info = read_info(network)

pa = load(sprintf('dat/pa.%s.mat', network)); 
pa = pa.pa; 

pa_data = load(sprintf('dat/pa_data.%s.mat', network)); 
pa_data = pa_data.pa_data; 

if info.format == consts.ASYM           

    pa_plot_one(network, 'u', pa.u, pa_data.u); 
    pa_plot_one(network, 'v', pa.v, pa_data.v); 

    pa_plot_one(network, 'a', pa.a, pa_data.a);

elseif info.format == consts.SYM 

    pa_plot_one(network, 'a', pa.a, pa_data.a);

elseif info.format == consts.BIP

    pa_plot_one(network, 'u', pa.u, pa_data.u); 
    pa_plot_one(network, 'v', pa.v, pa_data.v); 

    pa_plot_one(network, 'a', pa.a, pa_data.a);

else
    error('*** Invalid format'); 
end


