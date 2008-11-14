#!/usr/bin/perl -w

use strict;
use warnings;

# read in the playlist from STDIN
my @playlist = <STDIN>;
# make a copy of the playlist before we start munging it
my @song_q = @playlist;
foreach my $song (@playlist) {
    chomp($song);
            #$song =~ s/,/\\,/g;
            #$song =~ s/ /\\ /g;
            if ( ! -e $song ) { warn qq(song '$song' does not exist\n); }
            # if we connect, grab data from stdin and shoot it to the server
            my ($buff, $len);
            warn qq(Opening file for streaming;\n'$song'\n);
            open(MP3FILE, $song) || die qq(Can't open $song : $!);
            while (($len = sysread(MP3FILE, $buff, 4096)) > 0) {
    	        unless ($conn->send($buff)) {
	                warn "Error while sending: " . $conn->get_error . "\n";
            	    last;
    	        } # unless ($conn->send($buff)) 
         	    # must be careful not to send the data too fast :)
    	        $conn->sync;
            } # while (($len = sysread(MP3FILE, $buff, 4096)) > 0)
            close(MP3FILE);
            warn qq(Closing file;\n$song\n);
        } # foreach my $song (@playlist)
    } # while ( -e q(/tmp/streambake.die) 

    # all done
    $conn->close;
} else {
    warn "couldn't connect...\n";
}
