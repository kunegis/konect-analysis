#
# Plot inter-event distributions.
#
# This is the first Julia code in KONECT, and therefore can serve as an
# example of how to do it. 
#
# PARAMETERS 
#	$network	Network name
#
# INPUT FILES
#	dat/out2.$network
#
# OUTPUT FILES
# 	plot/inter.$type.$network.png
#		$type:
#		a	Overall distribution, log-log
#		al	Overall distribution, lin-log
#

using PyPlot;

include("step_full.jl");

network = ENV["network"]; 

T = readdlm("dat/out2.$network", '\t'); 

t = T[:,4];  
sort!(t);

d = t[2:end] - t[1:end-1];
d = d[d .!= 0]; 

fig = figure("Title", figsize=(5,3.7)); 

step_full(d);

xlabel("Inter-event time (t) [s]");
ylabel("P(x ≥ t)");
tight_layout();

# Day line
axvline(60 * 60 * 24, linestyle = "--", linewidth = 0.5, color = "k"); 

savefig("plot/inter.a.$network.png");

xscale("linear");

savefig("plot/inter.al.$network.png");

