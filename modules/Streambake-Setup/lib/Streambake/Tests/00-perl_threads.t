#!/usr/bin/env perl

use Config;
if ( $Config{usethreads} ) {
    return (
        required => q(yes), 
        description => "A check for Perl ithreads",
        output_text => "threads enabled",
    );
} else { 
    die qq(Perl not compiled with threads support);
}
