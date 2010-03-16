#!/usr/bin/env perl

# set up some defaults for the data to be returned to the Setup module
my %return_hash = (
    mod_name        => q(Shout),
    mod_required    => q(yes), 
    mod_description => q(a Perl interface to 'libshout'),
    mod_available   => 0,
    mod_version     => q(),
    mod_purpose     => q(streaming),
);

eval 'use Shout; Shout->new(); ';

# if there's no error from the eval, then the module is available
if ( $@ ) {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} = $@;
} else {
    $return_hash{mod_available} = 1;
    $return_hash{mod_version} = $Shout::VERSION;
} # if ( $@ )

return %return_hash;
