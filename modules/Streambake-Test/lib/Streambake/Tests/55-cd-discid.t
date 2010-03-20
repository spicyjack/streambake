#!/usr/bin/env perl

# set up some defaults for the data to be returned to the Setup module
my %return_hash = (
    mod_name        => q(cd-discid),
    mod_required    => q(no), 
    mod_description => q(Returns the values needed to perform a FreeDB lookup),
    mod_available   => 0,
    mod_version     => q(),
    mod_provides    => { 
        discid => 75,
    },
);
# this protects the test if the module is not installed/available
# FIXME 
# - look in a few different standard places for the lame binary
# - ask 'which'
# - check environment variables?

# if there's no error from the eval, then the module is available
if ( $@ ) {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} = $@;
} else {
    $return_hash{mod_available} = 1;
    $return_hash{mod_version} = $DBD::Oracle::VERSION;
} # if ( $@ )

return %return_hash;
