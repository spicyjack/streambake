#!/usr/bin/perl -w

use strict;
use Shout;
use bytes;
use DateTime;
use Audio::TagLib;

# start the connection
my $conn = new Shout;
my $server = q(localhost);
my $port = q(7767);
my $user = q(source);
my $mountpoint = q(vault);

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
$conn->name(q(Spicyjack's Vault));
$conn->url(q(http://stream.portaboom.com:7767/vault));
$conn->description(q(Created with 'Streambake'...));
$conn->user($user);
$conn->password($icepass);
$conn->public(0);
$conn->format(SHOUT_FORMAT_MP3);
$conn->protocol(SHOUT_PROTOCOL_HTTP);
$conn->set_audio_info(SHOUT_AI_BITRATE => 256, SHOUT_AI_SAMPLERATE => 44100);

# try to connect
if ($conn->open) {
    warn qq(Connected to server '$server:$port' at )
        . qq(mountpoint '$mountpoint' as user '$user'\n);
    # read in the playlist from STDIN
    my @playlist = <STDIN>;
    # make a copy of the playlist before we start munging it
    my @song_q = @playlist;

    warn qq(Use the command 'touch /tmp/streambake.die' )
        . qq(to cause the server to exit\n);
    while ( ! -e q(/tmp/streambake.die) ) {
        my $current_song;

        my $song_q_length = scalar(@song_q);
        warn qq(There are currently $song_q_length songs in the song Q\n);
        my $random_song = int(rand($song_q_length));
        $current_song = splice(@song_q, $random_song, 1);
        chomp($current_song);
        warn qq(Current song is $current_song\n);
        if ( ! -e $current_song ) { 
            warn qq(File '$current_song' doesn't exist\n); 
            next;
        } # if ( ! -e $current_song ) 
        # if we connect, grab data from stdin and shoot it to the server
        my ($buff, $len);
        my $dt = DateTime->now();
        $dt->set_time_zone(q(PST8PDT));
        warn q(Opening file for streaming at ) 
            . sprintf(q(%02u), $dt->day) . $dt->month_abbr . $dt->year 
            . q( ) . $dt->hms . qq(\n);
        warn qq('$current_song'\n); 
        my $tf = Audio::TagLib::FileRef->new($current_song);
        my $artist = $tf->tag()->artist();
        my $album = $tf->tag()->album();
        my $title = $tf->tag()->title();

        my $metadata = $artist->toCString() . " - " 
                    . $album->toCString() . " - "
                    . $title->toCString();
        warn qq(Updating metadata to '$metadata'\n);
        $conn->set_metadata(
            "song" => "$metadata");
        undef $tf;
        open(MP3FILE, "< $current_song") 
            || die qq(Can't open $current_song : '$!');
        my $bytes_read;
        while (($len = sysread(MP3FILE, $buff, 4096)) > 0) {
    	    unless ( $conn->send($buff, 4096) ) {
	            warn "Error while sending: " . $conn->get_error . "\n";
                # 
    	        $conn->sync;
            	last;
            } # unless ($conn->send($buff)) 
            # must be careful not to send the data too fast :)
    	    $conn->sync;
        } # while (($len = sysread(MP3FILE, $buff, 4096)) > 0)
        close(MP3FILE);
        warn qq(Closing file;\n$current_song\n);

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
