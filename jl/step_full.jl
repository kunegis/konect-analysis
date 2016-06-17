#
# Draw a "full" step plot.
#
# PARAMETERS
#
#	x	(n) Values
#

function step_full(x)
    
    n = length(x);
    
    sort!(x);

    step(x,
         (n:-1:1) / n,
         linestyle="-");

    # If the Y axis was not logarithmic, we show also add the point
    # (x_sorted[end], 0) to the plot, making x_sorted[end] be there
    # twice. 
    
    xscale("log");
    yscale("log");

end
