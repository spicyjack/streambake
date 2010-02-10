#!/usr/bin/perl -w

# Copyright (c) 2010 by Brian Manning <elspicyjack at gmail dot com>
# PLEASE DO NOT E-MAIL THE AUTHOR WITH ISSUES; the proper venue for issues
# with this script is the Streambake mailing list:
# streambake@googlecode.com / http://groups.google.com/group/streambake

# TODO
# - log format could look something like:
# filename
# time - opening file
# time - updating metadata
# time - closing file
# - simple config file format
# name: value
# name = value <-- easier to reuse when you go to Config::IniFiles
# - maybe use Getopt::Long to parse config info from the config file that's
# read into a $scalar

=pod

=head1 NAME

B<simplebake.pl> - Using a list of MP3/OGG files, stream those files to an
Icecast server.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

######################
# Simplebake::Server #
######################
package Simplebake::Server;
use strict;
use warnings;

# a list of valid arguments to the get() method
my @valid_args 
    = qw(host port mount password user name url genre description public);

sub new {
    my $class = shift;
    my %sub_args = @_;

    my %args = %{$sub_args{args}};
    my $logger = $sub_args{logger};

    my $self = bless ({}, $class);

    # check to see if a source password was set in the environment
    if ( exists $ENV{ICECAST_SOURCE_PASS} ) {
        if ( exists $args{password} ) {
            if ( exists $args{verbose} ) {
                $logger->log(qq(WARN: password set on command line )
                    . qq(and in environment\n));
                $logger->log(qq(WARN: using password from environment\n));
            } # if ( exists $args{verbose} )
            $args{password} = $ENV{ICECAST_SOURCE_PASS};
        } # if ( exists $args{password} )
    } # if ( exists $ENV{ICECAST_SOURCE_PASS} ) 

    # set defaults here for any missing arugments
    # password first, since it gets a big fat error message
    if ( ! exists $args{password} ) {
        $logger->log(qq(WARN: using default source password of 'hackme';\n));
        $logger->log(qq(WARN: this is probably not what you want;\n));
        $logger->log(qq(WARN: set 'ICECAST_SOURCE_PASS' in environment,\n));
        $logger->log(qq(WARN: use --password on the command line,\n));
        $logger->log(qq(WARN: or set the password in a configuration file\n));
        $args{password} = q(hackme);
    } # if ( ! exists $args{password} )

    # now the rest of the arguments
    if ( ! exists $args{host} ) { $args{host} = q(localhost); }
    if ( ! exists $args{port} ) { $args{port} = q(8000); }
    if ( ! exists $args{user} ) { $args{user} = q(source); }
    if ( ! exists $args{mount} ) { $args{mount} = q(default); }
    if ( ! exists $args{name} ) { $args{name} = q(Streambake - simplebake.pl);
    if ( ! exists $args{url} ) { $args{url} =
        q(http://code.google.com/p/streambake/) 
    }; # if ( ! exists $args{url} )
    if ( ! exists $args{public} ) { $args{public} = 0; }

    # create the Shout object
    $conn = Shout->new(%args);
    # set some other misc settings
    $conn->format(SHOUT_FORMAT_MP3);
    $conn->protocol(SHOUT_PROTOCOL_HTTP);
    $conn->set_audio_info(
        SHOUT_AI_BITRATE => 256, 
        SHOUT_AI_SAMPLERATE => 44100,
    ); # $self->{_conn}->set_audio_info

    # add the connection object to the attributes of this object
    $self->{_conn} = $conn;
    # return this object to the caller
    return $self;
} # sub new

######################
# Simplebake::Logger #
######################
package Simplebake::Logger;
use strict;
use warnings;
use POSIX qw(strftime);

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless ({}, $class);
    if ( exists $args{logfile} ) {
        $self->{_logfile} = $args{logfile};
        open (LOG, qq( > $logfile)) 
            || die q(Can't open logfile ) . $self->{_logfile} . qq(: $!);
        $self->{_OUTFH} = *LOG;
    } else {
        $self->{_OUTFH} = *STDOUT;
    } # if ( exists $args{logfile} )

    $self->{_quiet} = 0;
    if ( exists $args{quiet} ) {
        $self->{_quiet} = 1;
    } # if ( exists $args{quiet} )

    # return this object to the caller
    return $self;
} # sub new

sub log {
    my $self = shift;
    my $msg = shift;

    my $FH = $self->{_OUTFH};
    print $FH $msg . qq(\n);
} # sub log

sub timelog {
    my $self = shift;
    my $msg = shift;
    my $timestamp = POSIX::strftime( q(%c), localtime() );

    my $FH = $self->{_OUTFH};
    print $FH $timestamp . q(: ) . $msg . qq(\n);
} # sub timelog

################
# package main #
################
package main;
use strict;
use warnings;

use Getopt::Long;
use Shout;
use bytes;

    # script arguments 
    my %args; 

    my $parser = Getopt::Long::Parser->new();

    # pass in a reference to the args hash as the first argument
    $parser->getoptions(
        \%args,
        q(verbose|v),
        q(quiet|q),
        q(help|h),
        q(config|c=s),
        q(logfile|l=s),
        q(host|h=s),
        q(port|p=s),
        q(mount|m=s),
        q(nonblocking|b),
        q(password|a=s),
        q(user|u=s),
        q(name|n=s),
        q(url|r=s),
        q(genre|g=s),
        q(description|d=s),
        q(public|x),
        q(filelist|f=s),
    ); # $parser->getoptions

# -v|--verbose       Verbose script execution

=head1 SYNOPSIS

 -q|--quiet         Quiet script execution; only prints errors
 -h|--help          Shows this help text
 -c|--config        Configuration file to use for script options
 -l|--logfile       Logfile to use for script output; default is STDOUT
 -h|--host          Server hostname or IP address to connect to
 -p|--port          Server port to connect to
 -m|--mount         Mountpoint, where clients connect to on the server
 -b|--nonblocking   Set server connection to be non-blocking
 -a|--password      Server password
 -u|--user          Server username (defaults to 'source')
 -n|--name          Name of the stream (shown along with title metadata)
 -r|--url           URL to the homepage of the stream
 -g|--genre         Genre (used in directory listings on YP servers)
 -d|--description   Description of the stream
 -x|--public        Public flag, lists stream on YP servers when set
 -f|--filelist      File containing a list of MP3/OGG files to stream

Example usage:

 simplebake.pl --name stream.example.com --port 7767 \
    --mount somemount --filelist /path/to/mp3-ogg.txt

You can set the environment variable C<ICECAST_SOURCE_PASS> with the source
password to the Icecast server, and the script will use that instead of the
source password set elsewhere.

=cut

    # create a logger object
    my $logger = Streambake::Logger->new(%args);

    my $conn = Streambake::Server->new(
        args    => \%args,
        logger  => $logger,
    ); # my $conn = Streambake::Server->new
    # install a signal handler that causes us to exit on HUP

    $SIG{HUP} = $SIG{INT} = sub { 
        # close the connection to the icecast server
        $conn->close();
        die q(script sent HUP; exiting...); 
    } # $SIG{HUP}

    # verify the playlist file can be opened and then read it
    if ( -r $args{filelist} ) {
        open(FL, "< " . $args{filelist}) 
            || die q( ERR: could not open ) . $args{filelist} . qq(: $!);
        @playlist = <FL>;
    } else {
        die q( ERR: File ) . $args{filelist} . q( does not exist or )
            . q(is not readable);
    } # if ( -r $args{filelist} )

    # try to connect to the icecast server
    if ( $conn->open() ) {
        $logger->timelog(q(INFO: Connected to server ') 
            . $conn->get(q(host)) . q(:) . $conn->get(q(port)) 
            . q(' at mountpoint ') 
            . $conn->get(q(mount)) 
            . q(' as user ')
            . $conn->get(q(user)) 
            . qq('\n);

        # make a copy of the playlist before we start munging it
        my @song_q = @playlist;

        # endless loop
        while ( 1 ) {
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
            # just get the name of the file for metadata
            my @song_metadata = split(q(/), $current_song);
            # generate the metadata items using the song's filename
            my $track_name = $song_metadata[-1];
            $track_name =~ s/\.mp3$//;
            # remove leading numbers with dashes from the track name
            if ( $track_name =~ /^\d+-/ ) { $track_name =~ s/^\d+-//; }
            # remove leading numbers with spaces from the trackname
            if ( $track_name =~ /^\d+ / ) { $track_name =~ s/^\d+ //; }
            my $album_name = $song_metadata[-2];
            my $artist_name = $song_metadata[-3];
            # if we connect, grab data from stdin and shoot it to the server
            my ($buff, $len);

            warn q(Opening file for streaming at ) 
                . sprintf(q(%02u), $dt->day) . $dt->month_abbr . $dt->year 
                . q( ) . $dt->hms . qq(\n);
            warn qq('$current_song'\n); 
            $conn->set_metadata( 
                "song" => "$artist_name - $album_name - $track_name" );
            #undef $tf;
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
        } # while ( 1 )
    } else {
        warn qq(couldn't connect to server; ) . $conn->get_error . qq(\n);
    } # if ($conn->open)

=head1 DESCRIPTION

B<simplebake.pl> is meant to be used as a quick testing script to verify that
all of the correct C libraries and Perl modules needed to stream audio via an
Icecast server are installed, and that all of the Icecast login information
provided to the script is valid.  The script can also be used for as a simple
script for streaming a list of files on a local filesystem.  The script aims
to use as few non-core Perl modules as possible, so that it will run with any
modern (5.8-ish and newer) Perl installation with no extra libraries beyond
L<Shout> installed.

=head2 Generating Filelists

You can generate filelists with something like this on *NIX:

 find /path/to/your/files -name "*.mp3" > output_filelist.txt

=head2 Configuration File Syntax 

You can use the C<--config> switch to specify the name of a file to be parsed
for script configuration options.  The options understood by the script are
the same options shown in the SYNOPSIS section above.  The configuration file
consists of key/value pairs, one per line.  Any line that starts with the
pound sign/comment character is ignored.

Example configuration file:

 # any line that starts with the comment character is ignored
 host: stream.example.com
 port: 7767
 mount: somemount
 password: $om3P$$w0rd
 filelist: /path/to/mp3-ogg.txt

=head1 EXITING SCRIPT

You can send the C<HUP> signal at any time to cause the script to exit.

 kill -HUP <<PID of script>>

=head1 AUTHOR

Brian Manning, C<< <elspicyjack at gmail dot com> >>

=head1 BUGS

Please report any bugs or feature requests to 
C<< <streambake at googlegroups dot com> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc simplebake.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008,2010 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set sw=4 ts=4
