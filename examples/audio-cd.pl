#!/usr/bin/env perl

# quick demo of Audio::CD

use strict;
use warnings;
use Audio::CD;

my $CD = Audio::CD->init;
my $cddb = $CD->cddb;
my $disc_id = $cddb->discid;
print qq(Disc ID of currently inserted disc is: ) 
    . sprintf(q(0x%x), $disc_id) . qq(\n);
