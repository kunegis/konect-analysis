#
# Plot node-level interevent time distributions.
#
# PARAMETERS
#	$network
#
# INPUT FILES
#	dat/out2.$network
#	dat/statistic.format.$network
#
# OUTPUT FILES
#	plot/inter2.{auv}{,l}.$network.png
#

using PyPlot;

include("read_statistic.jl");
include("konect_consts.jl"); 
include("step_full.jl"); 

network = ENV["network"]; 

format = read_statistic("format", network)[1];

T = readdlm("dat/out2.$network", '\t'); 

#
# c	Character
# x	Values
# t	Timestamps
#
function inter2_one(c, network, x, t)

    d = [];
    for i in unique(x) 
##        x_i = x[x .== i];
        t_i = t[x .== i];
        sort!(t_i);
        d_i = t_i[2:end] - t_i[1:end-1];
        d = [d ; d_i]; 
    end
    d = d[d .!= 0 ]; 

    println("inter2: $network $c length(d) = $(length(d))"); 
    
    close(); 

    fig = figure("Title", figsize=(5,3.7)); 

    step_full(d);

    xlabel("Inter-event time (t) [s]");
    ylabel("P(x ≥ t)");

    tight_layout();

    # Day line
    axvline(60 * 60 * 24, linestyle = "--", linewidth = 0.5, color = "k"); 

    savefig("plot/inter2.$c.$network.png");
    xscale("linear");
    c2= string(c, "l");
    savefig("plot/inter2.$c2.$network.png");
end

if format == KONECT_BIP
    inter2_one('u', network, T[:,1], T[:,4]);
    inter2_one('v', network, T[:,2], T[:,4]);
    inter2_one('a', network, [T[:,1]; T[:,2] + maximum(T[:,1])], [T[:,4]; T[:,4]]); 
elseif format == KONECT_SYM
    inter2_one('a', network, [T[:,1]; T[:,2]], [T[:,4]; T[:,4]]);
elseif format == KONECT_ASYM
    inter2_one('u', network, T[:,1], T[:,4]);
    inter2_one('v', network, T[:,2], T[:,4]);
    inter2_one('a', network, [T[:,1]; T[:,2]], [T[:,4]; T[:,4]]);
else
    @assert false
end

