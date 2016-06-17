#
# Read a statistic from a file.
#
# PARAMETERS
#	statistic	Statistic name
#	network		Network name
#
# INPUT FILES
#	dat/statistic.$statistic.$network
#
function read_statistic(statistic, network)

    data = readdlm("dat/statistic.$statistic.$network");

    return data; 
end
