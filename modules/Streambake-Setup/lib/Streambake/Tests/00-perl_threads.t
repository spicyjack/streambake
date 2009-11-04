#!/usr/bin/env perl

use Config;
if ( $Config{usethreads} ) {
    # threads available
    return (
        required => q(yes), 
        description => "A check for Perl ithreads",
        output_text => "threads enabled",
    );
} # if ( $Config{usethreads} )
