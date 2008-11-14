#!/usr/bin/perl -w

use strict;
use warnings;

# read in the playlist from STDIN
my @playlist = <STDIN>;
# make a copy of the playlist before we start munging it
my @song_q = @playlist;
while ( scalar(@song_q) != 0 ) {
    chomp($song);
    my $song_q_length = scalar(@song_q);
    my $random_song = int(rand($song_q_length));
    my (@high_q, @low_q);
    if ( $random_song == 0 ) {
        @high_q = @song_q[1, $song_q_length - 1];
    } 
}
