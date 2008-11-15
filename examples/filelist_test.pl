#!/usr/bin/perl -w

use strict;
use warnings;

# read in the playlist from STDIN
my @playlist = <STDIN>;
# make a copy of the playlist before we start munging it
my @song_q = @playlist;
while ( ! -e q(/tmp/streambake.die) ) {
    my $current_song;
    my $song_q_length = scalar(@song_q);
    print qq(There are currently $song_q_length songs in the song Q\n);
    my $random_song = int(rand($song_q_length));
    $current_song = splice(@song_q, $random_song, 1);
    chomp($current_song);
    print qq(Current song is $current_song\n);
    if ( scalar(@song_q) == 0 ) {
        print qq(Reloading song queue;\n);
        @song_q = @playlist;
    } # if ( scalar(@song_q) == 0 )  
    sleep 2;
} # while ( -e q(/tmp/streambake.die) )

