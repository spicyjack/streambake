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

my @playlist;

# try to connect
if ($conn->open) {
    warn qq(Connected to server '$server:$port' at )
        . qq(mountpoint $mountpoint as user '$user'\n);
    $conn->set_metadata(
        "song" => "Streaming from standard in; no metadata available");

    while ( ! -e q(/tmp/streambake.die) ) {
        #my $playlist_file = q(/home/ftp/other/test.m3u);
        my $playlist_file = q(/home/ftp/other/pl-all-mp3.m3u);
        warn qq(Reading playlist file '$playlist_file'\n);
        open (PLAYLIST, $playlist_file);
        @playlist = <PLAYLIST>;
        close(PLAYLIST);
        warn qq(Found ) . scalar(@playlist) . qq( songs in playlist\n);
        #chomp(@playlist);
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
