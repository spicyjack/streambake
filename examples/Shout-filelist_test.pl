#!/usr/bin/perl -w

use strict;
use Shout;
use bytes;

# start the connection
my $conn = new Shout;
my $server = q(localhost);
my $port = q(8000);
my $user = q(source);
my $mountpoint = q(getbaked);

my $icepass;
if ( exists $ENV{ICECAST_SOURCE_PASS} ) {
    $icepass = $ENV{ICECAST_SOURCE_PASS};
} else {
    warn qq(WARNING: using default password of 'hackme';\n);
    warn qq(WARNING: this is probably not what you want\n);
    warn qq(WARNING: missing 'ICECAST_SOURCE_PASS' in your environment\n);
    $icepass = q(hackme);
} # if ( exists $ENV{ICECAST_SOURCE_PASS} ) 

# setup all the params
$conn->host($server);
$conn->port($port);
$conn->mount($mountpoint);
$conn->user($user);
$conn->password($icepass);
$conn->public(0);
$conn->format(SHOUT_FORMAT_MP3);
$conn->protocol(SHOUT_PROTOCOL_HTTP);
$conn->set_audio_info(SHOUT_AI_BITRATE => 256, SHOUT_AI_SAMPLERATE => 44100);

# try to connect
if ($conn->open) {
    warn qq(Connected to server '$server:$port' at )
        . qq(mountpoint $mountpoint as user '$user'\n);
    $conn->set_metadata(
        "song" => "Streaming from standard in; no metadata available");

    # read in the playlist from STDIN
    my @playlist = <STDIN>;
    # make a copy of the playlist before we start munging it
    my @song_q = @playlist;

    while ( ! -e q(/tmp/streambake.die) ) {
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
            #print qq(- Selected ) . scalar(@low_q) . qq( into low queue\n);
            @high_q = @song_q[($random_song + 1) .. $song_q_length - 1];
            #print qq(- Selected ) . scalar(@high_q) . qq( into high queue\n);
        } # if ( $random_song == 0 )
        chomp($current_song);
        print qq(Current song is $current_song\n);
        if ( ! -e $current_song ) { 
            warn qq(File '$current_song' doesn't exist\n); 
        } # if ( ! -e $current_song ) 
        # if we connect, grab data from stdin and shoot it to the server
        my ($buff, $len);
        warn qq(Opening file for streaming;\n'$current_song'\n);
        open(MP3FILE, $current_song) || die qq(Can't open $current_song : $!);
        while (($len = sysread(MP3FILE, $buff, 4096)) > 0) {
    	    unless ($conn->send($buff)) {
	            warn "Error while sending: " . $conn->get_error . "\n";
            	last;
            } # unless ($conn->send($buff)) 
            # must be careful not to send the data too fast :)
    	    $conn->sync;
        } # while (($len = sysread(MP3FILE, $buff, 4096)) > 0)
        close(MP3FILE);
        warn qq(Closing file;\n$current_song\n);

        # combine the leftovers back into the song_q again
        @song_q = ( @low_q, @high_q );
        if ( scalar(@song_q) == 0 ) {
            print qq(Reloading song queue;\n);
            @song_q = @playlist;
        } # if ( scalar(@song_q) == 0 )  
    } # while ( -e q(/tmp/streambake.die) 

    # all done
    $conn->close;
} else {
    warn qq(couldn't connect to server; ) . $conn->get_error . qq(\n);
} # if ($conn->open)
