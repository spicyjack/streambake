#!/usr/bin/env perl

# set up some defaults for the data to be returned to the Setup module
my %return_hash = (
    mod_name        => q(LAME),
    mod_required    => q(no), 
    mod_description => q(Create compressed audio files),
    mod_available   => 0,
    mod_version     => q(),
    mod_purpose     => q(rencoding),
);
# this protects the test if the module is not installed/available
# FIXME 
# - look in a few different standard places for the lame binary
# - ask 'which'
# - check environment variables?
my $lame = qx(lame --help | head -n 1 | tr -d '\n');

# if there's no error from the eval, then the module is available
if ( $lame !~ /version/ ) {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} = $@;
} else {
    $return_hash{mod_available} = 1;
    # pull the version number out of the help string
    $lame =~ s/.*version (\d+\.\d+\.\d+).*/$1/;
    $return_hash{mod_version} = $lame;
} # if ( $@ )

return %return_hash;
