#!/usr/bin/env perl

use Config;
if ( $Config{usethreads} ) {
    return "threads enabled";
} else { 
    die qq(Perl not compiled with threads support);
}
