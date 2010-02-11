#!/usr/bin/perl -w

# Copyright (c) 2010 by Brian Manning <elspicyjack at gmail dot com>
# PLEASE DO NOT E-MAIL THE AUTHOR WITH ISSUES; the proper venue for issues
# with this script is the Streambake mailing list:
# streambake@googlecode.com / http://groups.google.com/group/streambake

# TODO
# - consume the config options into an object (Simplebake::Config)
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

=head1 NAME

B<simplebake.pl> - Using a list of MP3/OGG files, stream those files to an
Icecast server.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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

=head1 DESCRIPTION

B<simplebake.pl> is meant to be used as a quick testing script to verify that
all of the correct C libraries and Perl modules needed to stream audio via an
Icecast server are installed, and that all of the Icecast login information
provided to the script is valid.  The script can also be used for as a simple
script for streaming a list of files on a local filesystem.  The script aims
to use as few non-core Perl modules as possible, so that it will run with any
modern (5.8-ish and newer) Perl installation with no extra libraries beyond
L<Shout> installed.

=head1 OBJECTS

=head2 Simplebake::Config

=cut 

######################
# Simplebake::Config #
######################
package Simplebake::Config;
use strict;
use warnings;

=over

=item new( )

Creates the L<Simplebake::Config> object, and parses out options using
L<Getopt::Long>.

=cut

sub new {
    my $class = shift;

    my $self = bless ({}, $class);

    # script arguments 
    my %args; 

    # FIXME move this into it's own object, and move it closer to the top of
    # this file, place this new object in the correct order of the POD
    # documentation
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

    $self->{_args} = \%args;
    return $self;
} # sub new

# -v|--verbose       Verbose script execution

=item get($key)

Returns the scalar value of the key passed in as C<key>, or C<undef> if the
key does not exist in the L<Simplebake::Config> object.

=cut

sub get {
    my $self = shift;
    my $key = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) { return $args{$key}; }
    return undef;
} # sub get

=item set( key => $value )

Sets in the L<Simplebake::Config> object the key/value pair passed in as
arguments.  Returns the old value if the key already existed in the
L<Simplebake::Config> object, or C<undef> otherwise.

=cut

sub set {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) { 
        my $oldvalue = $args{$key};
        $args{$key} = $value;
        $self->{_args} = \%args;
        return $oldvalue;
    } else {
        $args{$key} = $value;
        $self->{_args} = \%args;
    } # if ( exists $args{$key} )
    return undef;
} # sub get

=item get_args( )

Returns a hash containing the parsed script arguments.

=cut

sub get_args {
    my $self = shift;
    # hash-ify the return arguments
    return %{$self->{_args}};
} # get_args

=back

=head2 Simplebake::Server

=cut

package Simplebake::Server;
######################
# Simplebake::Server #
######################
use strict;
use warnings;

# a list of valid arguments to the get() method
my @valid_args 
    = qw(host port mount password user name url genre description public);

=over 

=item new(config => $config, logger => $logger)

Creates the L<Simplebake::Server> object, and populates it with default values
if no C<%args> hash is passed into it.  Returns the copy to the object that is
created.

=cut

sub new {
    my $class = shift;
    my %args = @_;

    # pull the arguments hash and the logger object from the arguments to this
    # method
    my $config = $args{config};
    my $logger = $args{logger};

    # bless this class into an object
    my $self = bless ({}, $class);

    # check to see if a source password was set in the environment
    if ( exists $ENV{ICECAST_SOURCE_PASS} ) {
        if ( defined $config->get(q(password)) ) {
            if ( defined $config->get(q(verbose)) ) {
                $logger->log(qq(WARN: password set on command line )
                    . qq(and in environment\n));
                $logger->log(qq(WARN: using password from environment\n));
            } # if ( exists $args{verbose} )
            $config->set(password => $ENV{ICECAST_SOURCE_PASS});
        } # if ( exists $args{password} )
    } # if ( exists $ENV{ICECAST_SOURCE_PASS} ) 

    # set defaults here for any missing arugments
    # password first, since it gets a big fat error message
    if ( ! defined $config->get(q(password)) ) {
        $logger->log(qq(WARN: using default source password of 'hackme';\n));
        $logger->log(qq(WARN: this is probably not what you want;\n));
        $logger->log(qq(WARN: set 'ICECAST_SOURCE_PASS' in environment,\n));
        $logger->log(qq(WARN: use --password on the command line,\n));
        $logger->log(qq(WARN: or set the password in a configuration file\n));
        $config->set( password => q(hackme) );
    } # if ( ! exists $args{password} )

    # now the rest of the arguments
    $config->set( host => q(localhost) )
        unless ( defined $config->get(q(host)) );
    $config->set( port => q(8000) )
        unless ( defined $config->get(q(port)) );
    $config->set( user => q(source) )
        unless ( defined $config->get(q(user)) );
    $config->set( mount => q(default) )
        unless ( defined $config->get(q(mount)) );
    $config->set( name => q(Streambake - simplebake.pl) )
        unless ( defined $config->get(q(name)) );
    $config->set( url => q(http://code.google.com/p/streambake/) )
        unless ( defined $config->get(q(url)) );
    $config->set( public => 0 )
        unless ( defined $config->get(q(user)) );

    # we should have things set up enough now to be able to create the Shout
    # object
    my $conn = Shout->new(%args);
    die qq( ERR: could not create Shout object: $!) unless ( defined $conn );
    # set some other misc settings
    $conn->format(q(SHOUT_FORMAT_MP3));
    $conn->protocol(q(SHOUT_PROTOCOL_HTTP));
    $conn->set_audio_info(
        SHOUT_AI_BITRATE => 256, 
        SHOUT_AI_SAMPLERATE => 44100,
    ); # $self->{_conn}->set_audio_info

    # add the connection object to the attributes of this object
    $self->{_conn} = $conn;
    # return this object to the caller
    return $self;
} # sub new

=item open( )

Calls the C<open()> method of the L<Shout> module.  Returns C<1> upon success,
or dies and returns the error message if the C<open()> call fails.

=cut

sub open {
    my $self = shift;
    my $conn = $self->{_conn};

    die q( ERR: Failed to open connection: ) . $conn->get_error()
        unless $conn->open();
    return 1;
} # sub open

=item close( )

Calls the C<close()> method of the L<Shout> module.  Returns C<1> upon
success, or dies and returns the error message if the C<close()> call fails.

=cut

sub close {
    my $self = shift;
    my $conn = $self->{_conn};

    die q( ERR: Failed to open connection: ) . $conn->get_error()
        unless $conn->close();
    return 1;
} # sub close

=item set_metadata( $metadata )

Sets the stream metadata on the Icecast server to C<$metadata>.  Returns
C<true> if the call succeeds, or C<undef> if the call fails.

=cut

sub set_metadata {
    my $self = shift;
    my $metadata = shift;
    my $conn = $self->{_conn};

    # return success if we can set the metadata
    return 1 if ( $conn->set_metadata($metadata) );
    # return failure if something went wrong
    return undef;
} # sub set_metadata

=item send(data => $buffer, [ length => $length ])

Sends C<$buffer> data of optional C<$length> to the Icecast server.  If
C<$length> is missing, it will be computed by the L<Shout> module.  Returns
C<true> if the call succeeds, or sets an error message and returns C<undef> if
the call fails.

=cut

sub send {
    my $self = shift;
    my %args = @_;

    my $conn = $self->{_conn};

    # we always need the data to be sent; the length is optional, Shout.pm
    # computes it if it's missing.
    if ( ! exists $args{data} ) {
        die q| ERR: send() called without 'data' argument|;
    } # if ( ! exists $args{data} )

    # die if something went wrong
    if ( exists $args{length} ) {
        die q( ERR: Failed to send data: ) . $conn->get_error()
            unless ( $conn->send($args{data}, $args{length}) );
    } else {
        die q( ERR: Failed to send data: ) . $conn->get_error()
            unless ( $conn->send($args{data}) );
    } # if ( exists $args{length} )
    return 1;
} # sub set_metadata

=item sync( )

Sleep until the connection is ready for more data; blocks until the server is
ready for more data.  Always returns a true value.

=cut

sub sync {
    my $self = shift;
    my $conn = $self->{_conn};

    $conn->sync();
    return 1;
} # sub sync

=back

=head2 Simplebake::Logger

=cut

######################
# Simplebake::Logger #
######################
package Simplebake::Logger;
use strict;
use warnings;
use POSIX qw(strftime);

=over 

=item new($config)

Creates the L<Simplebake::Logger> object, and sets up various filehandles
needed to log to files or C<STDOUT>.  Requires a L<Simplebake::Config> object
as the argument, so that options having to deal with logging can be
parsed/acted upon.

=cut

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless ({}, $class);
    if ( exists $args{logfile} ) {
        $self->{_logfile} = $args{logfile};
        open (LOG, q( > ) . $self->{_logfile}) 
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

=item log($message)

Log C<$message> to the logfile, or I<STDOUT> if the B<--logfile> option was
not used.

=cut

sub log {
    my $self = shift;
    my $msg = shift;

    my $FH = $self->{_OUTFH};
    print $FH $msg . qq(\n);
} # sub log

=item timelog($message)

Log C<$message> with a timestamp to the logfile, or I<STDOUT> if the
B<--logfile> option was not used.

=cut

sub timelog {
    my $self = shift;
    my $msg = shift;
    my $timestamp = POSIX::strftime( q(%c), localtime() );

    my $FH = $self->{_OUTFH};
    print $FH $timestamp . q(: ) . $msg . qq(\n);
} # sub timelog

=back

=cut

################
# package main #
################
package main;
use strict;
use warnings;

use Getopt::Long;
use Shout;
use bytes;

    # create a logger object
    my $config = Streambake::Config->new();
    # create a logger object
    my $logger = Streambake::Logger->new($config);

    my $conn = Streambake::Server->new(
        config  => $config,
        logger  => $logger,
    ); # my $conn = Streambake::Server->new
    # install a signal handler that causes us to exit on HUP

    $SIG{HUP} = sub { 
        # close the connection to the icecast server
        $conn->close();
        die q(Received SIGHUP; exiting...); 
    }; # $SIG{HUP}
    $SIG{INT} = sub { 
        # close the connection to the icecast server
        $conn->close();
        die q(Received SIGINT; exiting...); 
    }; # $SIG{HUP}

    # verify the playlist file can be opened and then read it
    # FIXME add a check for STDIN here
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
            . qq('\n)
        );

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

            $logger->timelog(q(Opening file for streaming));
            $logger->log(qq($current_song)); 
            $conn->set_metadata( 
                "song" => "$artist_name - $album_name - $track_name" );
            #undef $tf;
            open(MP3FILE, "< $current_song") 
                || die qq(Can't open $current_song : '$!');
            my $bytes_read;
            while (($len = sysread(MP3FILE, $buff, 4096)) > 0) {
                unless ( $conn->send($buff, length($buff)) ) {
                    warn "Error while sending: " . $conn->get_error . "\n";
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

=head1 MISCELLANIA

=head2 Generating Filelists

You can generate filelists with something like this on *NIX:

 find /path/to/your/files -name "*.mp3" > output_filelist.txt

=head2 Configuration File Syntax 

You can use the B<--config> switch to specify the name of a file to be parsed
for script configuration options.  The options understood by the script are
the same as the long options (B<--host>, B<--port>, etc) shown in the SYNOPSIS
section above.  The configuration file consists of key/value pairs, one per
line.  Any line that starts with the pound sign/comment character is ignored.

Example configuration file:

 # any line that starts with the comment character is ignored
 host: stream.example.com
 port: 7767
 mount: somemount
 password: $om3P$$w0rd
 filelist: /path/to/mp3-ogg.txt

=head1 EXITING SCRIPT

You can send the C<HUP> signal at any time to cause the script to exit.

 kill -HUP <PID of script>

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
