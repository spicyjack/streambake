#!/usr/bin/env perl

# set up some defaults for the data to be returned to the Setup module
my %return_hash = (
    mod_name        => q(DBD::Oracle),
    mod_required    => q(no), 
    mod_description => q(database driver for Oracle databases),
    mod_available   => 0,
    mod_version     => q(),
    mod_purpose     => q(source),
);
# this protects the test if the module is not installed/available
eval q( use DBD::Oracle; );

# if there's no error from the eval, then the module is available
if ( $@ ) {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} = $@;
} else {
    $return_hash{mod_available} = 1;
    $return_hash{mod_version} = $DBD::Oracle::VERSION;
} # if ( $@ )

return %return_hash;
