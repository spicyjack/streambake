#!/usr/bin/env perl

# set up some defaults for the data to be returned to the Setup module
my %return_hash = (
    mod_name        => q(cd-discid),
    mod_required    => q(no), 
    mod_description => q(Returns the values needed to perform a FreeDB lookup),
    mod_available   => 0,
    mod_version     => q(not available),
    mod_purpose     => q(freedb-id),
);

# version number not available from the command line
my $available = system(q(which cd-discid));

# if there's no error from the eval, then the module is available
if ( ( $available >> 8 ) != 0 ) {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} = $@;
} else {
    $return_hash{mod_available} = 1;
} # if ( $@ )

return %return_hash;
