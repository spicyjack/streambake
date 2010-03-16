#!/usr/bin/env perl

# quick demo of Audio::CD

use strict;
use warnings;
use MP3::Info;

if ( defined $ARGV[0] ) { 
    my $filename = $ARGV[0];
    #my $mp3 = MP3::Info->new($filename);
    my $mp3 = MP3::Info->new($filename);
    my $mp3_info_ref = get_mp3info($filename);
    my %mp3_info = %{$mp3_info_ref};
    print qq(Filename: ) . $ARGV[0] . qq(\n);
    foreach my $key ( sort(keys(%mp3_info)) ) {
        print qq($key -> ) . $mp3_info{$key} . qq(\n);
    } # foreach my $key ( sort(keys(%mp3_info)) )
} 

