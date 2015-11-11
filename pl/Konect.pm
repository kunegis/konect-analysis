package Konect; 

use strict;
use warnings; 

# Can be exported
our @EXPORT_OK = qw( bitwidth );

# Exported by default 
our @EXPORT    = qw( bitwidth );

#
# Given a number of nodes, return the bitwidth character for the
# corresponding unsigned type.  
#
sub bitwidth($) {
    my ($N) = @_;
    
    my $ret = 'a';

    while ($N > 1) {
	$N = int(sqrt($N)); 
	++$ret; 
    }

    return $ret; 
}

1;
