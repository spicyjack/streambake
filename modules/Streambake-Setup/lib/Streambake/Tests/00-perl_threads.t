#!/usr/bin/env perl

use Config;
my %return_hash = (
    mod_name        => q(ithreads),
    mod_required    => q(yes), 
    mod_description => q(Perl ithreads),
    mod_available   => 0,
    mod_version     => q(),
);
if ( $Config{usethreads} ) {
    # threads available
    $return_hash{mod_available} = 1;
    $return_hash{mod_version} = q(not applicable);
} else {
    # save the output of the eval to the return hash
    $return_hash{mod_test_failure} 
        = qq(threads not configured with this build of Perl);
}# if ( $Config{usethreads} )

return %return_hash;
