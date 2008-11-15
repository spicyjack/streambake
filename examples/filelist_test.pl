#!/usr/bin/perl -w

use strict;
use warnings;

# read in the playlist from STDIN
my @playlist = <STDIN>;
# make a copy of the playlist before we start munging it
my @song_q = @playlist;
while ( -e q(/tmp/streambake.die) ) {
    my $current_song;
    my $song_q_length = scalar(@song_q);
    print qq(There are currently $song_q_length songs in the song Q\n);
    my $random_song = int(rand($song_q_length));
    my (@high_q, @low_q);
    if ( $random_song == 0 ) {
        $current_song = $song_q[0];
        @low_q = ();
        @high_q = @song_q[1 .. $song_q_length - 1];
        print qq(- first song 0 chosen\n);
    } elsif ( $random_song == ( $song_q_length - 1 ) ) {
        $current_song = $song_q[$song_q_length - 1];
        @low_q = @song_q[0 .. $song_q_length - 2];
        @high_q = ();
        print qq(- last song ) . ($song_q_length - 1) . qq( chosen\n);
    } else {
        $current_song = $song_q[$random_song];
        print qq(- random song $random_song chosen\n);
        @low_q = @song_q[0 .. $random_song - 1];
        print qq(- Selected ) . scalar(@low_q) . qq( into the low queue\n);
        @high_q = @song_q[($random_song + 1) .. $song_q_length - 1];
        print qq(- Selected ) . scalar(@high_q) . qq( into the high queue\n);
    } # if ( $random_song == 0 )
    chomp($current_song);
    print qq(Current song is $current_song\n);
    @song_q = ( @low_q, @high_q );
    if ( scalar(@song_q) == 0 ) {
        print qq(Reloading song queue;\n);
        @song_q = @playlist;
    } # if ( scalar(@song_q) == 0 )  
} # while ( -e q(/tmp/streambake.die) )

