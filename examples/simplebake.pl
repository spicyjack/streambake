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

=head1 NAME

B<simplebake.pl> - Using a list of MP3/OGG files, stream those files to an
Icecast server.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 Script options:
 -q|--quiet         Quiet script execution; only prints errors
 -h|--help          Shows this help text
 -c|--config        Configuration file to use for script options
 -l|--logfile       Logfile to use for script output; default is STDOUT
 -f|--filelist      File containing a list of MP3/OGG files to stream
 -j|--gen-config    Generate a blank config file containing Shout options

 Shout module options used by this script:
 -o|--host          Server hostname or IP address to connect to
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

An object used for storing configuration data.

=head3 Object Methods

=cut 

######################
# Simplebake::Config #
######################
package Simplebake::Config;
use strict;
use warnings;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<Simplebake::Config> object, and parses out options using
L<Getopt::Long>.

=cut

# a list of valid arguments to the get() method
my @_valid_shout_args 
    = qw(host port mount password user name url genre description public);
# a list of valid arguments to the get() method
my @_valid_script_args = ( 
    @_valid_shout_args, qw(verbose quiet config logfile filelist) 
); # my @_valid_script_args 

sub new {
    my $class = shift;

    my $self = bless ({}, $class);

    # script arguments 
    my %args; 
    
    # parse the command line arguments (if any)
    my $parser = Getopt::Long::Parser->new();

    # pass in a reference to the args hash as the first argument
    $parser->getoptions(
        \%args,
        # script options
        q(verbose|v),
        q(quiet|q),
        q(help|h),
        q(config|c=s),
        q(logfile|l=s),
        q(filelist|f=s),
        q(gen-config|j),
        # Shout options
        q(host|o=s),
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
    ); # $parser->getoptions

    # assign the args hash to this object so it can be reused later on
    $self->{_args} = \%args;

    # dump and bail if we get called with --help
    if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

    # generate a config file and exit?
    if ( defined $self->get(q(gen-config)) ) {
        # apply the default configuration options to the Config object
        $self->_apply_defaults();
        # now print out the sample config file
        print qq(# sample simplebake config file\n);
        print qq(# any line that starts with '#' is a comment\n);
        print qq|# please quote your strings :)\n|;
        print qq(# generated on ) . POSIX::strftime( q(%c), localtime() ) 
            . qq(\n);
        foreach my $arg ( @_valid_shout_args ) {
            print $arg . q( = ) . $self->get($arg) . qq(\n);
        } # foreach my $arg ( @_valid_shout_args )
        # cheat a bit and add this last one
        print qq(filelist = /path/to/filelist.txt\n);
        exit 0;
    } # if ( exists $args{gen-config} )

    # read a config file if that's specified
    if ( defined $self->get(q(config)) && -r $self->get(q(config)) ) {
        open( CFG, q(<) . $self->get(q(config)) );
        my @config_lines = <CFG>;
        foreach my $line ( @config_lines ) {
            chomp $line;
            warn qq(VERB: parsing line '$line'\n) 
                if ( defined $self->get(q(verbose)));
            next if ( $line =~ /^#/ );
            my ($key, $value);
            if ( scalar(grep($line, @_valid_script_args)) > 0 ) {
                ($key, $value) = split(/\s*=\s*/, $line);
                $self->set($key => $value);
            } else {
                warn qq|WARN: unknown config key: $key ($value)\n|;
            } # if ( grep($key, @_valid_shout_args) > 0 )
        } # foreach my $line ( @config_lines )
    } # if ( exists $args{config} && -r $args{config} )

    # check to see if a source password was set in the environment
    if ( exists $ENV{ICECAST_SOURCE_PASS} ) {
        if ( defined $self->get(q(password)) ) {
            if ( defined $self->get(q(verbose)) ) {
                warn qq(WARN: password set on command line )
                    . qq(and in environment\n);
                warn qq(WARN: using password from environment\n);
            } # if ( exists $args{verbose} )
            $self->set(key => q(password), value => $ENV{ICECAST_SOURCE_PASS});
        } # if ( exists $args{password} )
    } # if ( exists $ENV{ICECAST_SOURCE_PASS} ) 

    # some checks to make sure we have needed arguments
    die qq( ERR: script called without a --filelist argument;\n)
        . qq( ERR: run script with --help switch for usage examples\n)
        unless ( defined $self->get(q(filelist)) );

    # apply script defaults to whatver remaining key/value pairs don't have
    # anything set
    $self->_apply_defaults();

    # return this object to the caller
    return $self;
} # sub new

# -v|--verbose       Verbose script execution

# set defaults here for any missing arugments
sub _apply_defaults {
    my $self = shift;
    # set some defaults if they haven't been set by now
    $self->set( host => q(localhost) )  unless ( defined $self->get(q(host) ) );
    $self->set( port => q(8000) ) unless ( defined $self->get(q(port)) );
    $self->set( user => q(source) ) unless ( defined $self->get(q(user)) );
    $self->set( mount => q(default) ) unless ( defined $self->get(q(mount)) );
    $self->set( name => q(Streambake - simplebake.pl) )
        unless ( defined $self->get(q(name)) );
    $self->set( url => q(http://code.google.com/p/streambake/) )
        unless ( defined $self->get(q(url)) );
    $self->set( genre => q(mish-mash) ) 
        unless ( defined $self->get(q(genre)) );
    $self->set( 
        description => q(I'm too lazy to set a simplebake description) )
        unless ( defined $self->get(q(description)) );
    $self->set( public => 0 ) unless ( defined $self->get(q(public)) );

    # generate a big fat error message unless we're generating a config file
    if ( ! defined $self->get(q(password)) ) {
        if ( ! defined $self->get(q(gen-config)) ) {
            warn qq(WARN: using default source password of 'hackme';\n);
            warn qq(WARN: this is probably not what you want;\n);
            warn qq(WARN: set 'ICECAST_SOURCE_PASS' in environment,\n);
            warn qq(WARN: use --password on the command line,\n);
            warn qq(WARN: or set the password in a configuration file\n);
        } # if ( ! defined $self->get(q(gen-config)) )     
        $self->set( password => q(hackme) );
    } # if ( defined $self->get(q(password)) )
} # sub _apply_defaults

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

=item get_shout_args( )

Returns a hash containing the parsed script arguments.  The hash is filtered
so that it only contains valid arguments for the L<Shout> module.

=cut

sub get_shout_args {
    my $self = shift;

    my %return_args;
    foreach my $key ( @_valid_shout_args ) {
        warn qq(DEBG: key/value = '$key'/') . $self->get($key) . qq('\n)
            if ( defined $self->get(q(verbose)) );
        $return_args{$key} = $self->get($key);
    } # foreach my $key ( keys(%args) )
    return %return_args;
} # sub get_shout_args

=item get_server_connect_string( )

Returns the Icecast connect string for this server connection in a human
readable form (includes the C<http://> prefix).

=cut

sub get_server_connect_string {
    my $self = shift;
    
    return q(http://) . $self->get(q(host)) . q(:) . $self->get(q(port)) 
        . q(/) . $self->get(q(mount))
} # sub get_server_connect_string

=back

=head2 Simplebake::Server

Wraps the L<Shout> module with some defaults that may or may not work.
Actually, the "defaults" most likely won't work.

=head3 Object Methods

=cut

package Simplebake::Server;
######################
# Simplebake::Server #
######################
use strict;
use warnings;
use Shout;

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

    # create a copy of the args hash, then sanitize it prior to passing it
    # into Shout
    my %shoutargs = $config->get_shout_args();
    # we should have things set up enough now to be able to create the Shout
    # object
    my $conn = Shout->new(%shoutargs);
    die qq( ERR: could not create Shout object: $!) unless ( defined $conn );
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
    my @args = @_;
    my $conn = $self->{_conn};

    # return success if we can set the metadata
    return 1 if ( $conn->set_metadata(@_) );
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

=item get_error( )

Return the text error message returned if the last server operation failed.

=cut

sub get_error {
    my $self = shift;
    my $conn = $self->{_conn};

    return $conn->get_error();
} # sub sync

=back

=head2 Simplebake::Logger

A simple logger module, for logging script output and errors.

=head3 Object Methods

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
    my $config = shift;

    my $self = bless ({}, $class);
    if ( defined $config->get(q(logfile)) ) {
        $self->{_logfile} = $config->get(q(logfile));
        open (LOG, q( > ) . $self->{_logfile}) 
            || die q(Can't open logfile ) . $self->{_logfile} . qq(: $!);
        $self->{_OUTFH} = *LOG;
    } else {
        $self->{_OUTFH} = *STDOUT;
    } # if ( exists $args{logfile} )

    $self->{_quiet} = 0;
    if ( defined $config->get(q(quiet)) ) {
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
use bytes;

    # for holding a list of files
    my @playlist;
    # create a logger object
    my $config = Simplebake::Config->new();
    # create a logger object
    my $logger = Simplebake::Logger->new($config);

    my $conn = Simplebake::Server->new(
        config  => $config,
        logger  => $logger,
    ); # my $conn = Simplebake::Server->new
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
    if ( defined $config->get(q(filelist)) ) {
        # read from STDIN?
        if ( $config->get(q(filelist)) eq q(-) ) {
            @playlist = <STDIN>;
        # read from a filelist somewhere?
        } elsif ( -r $config->get(q(filelist)) ) {
            open(FL, "< " . $config->get(q(filelist)) )
                || die q( ERR: could not open ) . $config->get(q(filelist)) 
                    . qq(: $!);
            @playlist = <FL>;
            close(FL);
        # nope; bail!
        } else {
            die q( ERR: File ) . $config->get(q(filelist)) 
                . q( does not exist or is not readable);
        } # if ( -r $config->get(q(filelist)) )
    } else {
        die q( ERR: no --filelist argument specified; See --help for options);
    } # if ( defined $config->get(q(filelist)) ) 

    # try to connect to the icecast server
    if ( $conn->open() ) {
        $logger->timelog(q(INFO: Connected to server));
        $logger->log(q(- server ) . $config->get_server_connect_string() );
        $logger->log(q(- source user: ') . $config->get(q(user)) . q('));

        # make a copy of the playlist before we start munging it
        my @song_q = @playlist;

        # endless loop
        while ( 1 ) {
            my $current_song;
            my $song_q_length = scalar(@song_q);
            $logger->timelog(q(INFO: Queue status));
            $logger->log(q(- ) . $song_q_length 
                . qq( songs currently in the song Q));
            my $random_song = int(rand($song_q_length));
            $current_song = splice(@song_q, $random_song, 1);
            chomp($current_song);
            $logger->timelog(q(INFO: Streaming file));
            if ( length($current_song) > 70 ) {
                $logger->log(qq(- ...) . substr($current_song, -70));
            } else {
                $logger->log(qq(- $current_song));
            } # if ( length($current_song) > 70 )
            if ( ! -e $current_song ) { 
                $logger->timelog( qq(WARN: Missing file) );
                $logger->log(qq(- File '...) . substr($current_song, -60)
                    . q(' does not exist)); 
                # skip to the next song on the list
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

            # buffer for holding data read from the file
            my $buff;
            # update the metadata
            $logger->log(qq(- Updating metadata on server ) 
                . $config->get_server_connect_string() );
            $conn->set_metadata( 
                "song" => "$artist_name - $album_name - $track_name" );
            # open the file
            $logger->log(qq(- Opening file for streaming));
            open(MP3FILE, "< $current_song") 
                || die qq(Can't open $current_song : '$!');
            $logger->log(qq(- Streaming file to ) 
                . $config->get_server_connect_string() );
            while (sysread(MP3FILE, $buff, 4096) > 0) {
                # send a block of data, and error out if it fails
                unless ( $conn->send(data => $buff, length => length($buff)) ) {
                    $logger->timelog(q( ERR: while sending buffer to server:));
                    $logger->timelog(q( ERR:) . $conn->get_error);
                    $conn->sync;
                    last;
                } # unless ($conn->send($buff)) 
                # must be careful not to send the data too fast :)
                $conn->sync;
            } # while (sysread(MP3FILE, $buff, 4096) > 0)
            # close the file now that we've read it
            $logger->timelog(qq(INFO: Closing file));
            $logger->log(qq(- $current_song));
            close(MP3FILE);

            # check to see if the song Q is empty
            if ( scalar(@song_q) == 0 ) {
                $logger->timelog(qq(INFO: === Reloading song queue ===));
                @song_q = @playlist;
            } # if ( scalar(@song_q) == 0 )  
        } # while ( 1 )
    } else {
        $logger->timelog(qq(WARN: couldn't connect to server; ));
        $logger->timelog(q(WARN: ) . $conn->get_error());
    } # if ($conn->open)

=head1 MISCELLANIA

=head2 Generating Filelists

You can generate filelists with something like this on *NIX:

 find /path/to/your/media -name "*.mp3" > output_filelist.txt

=head2 Configuration File Syntax 

The configuration file consists of key/value pairs, one per line.  Any line
that starts with the pound sign/comment character is ignored.  The options
that can be used in the configuration file are the same as the long options
(B<--host>, B<--port>, etc) shown in the SYNOPSIS section above, minus the
leading dashes.  

Example configuration file:

 # any line that starts with the comment character is ignored
 host: stream.example.com
 port: 7767
 mount: somemount
 password: $om3P$$w0rd
 filelist: /path/to/mp3-ogg.txt

You can use the B<--gen-config> command line switch to generate a
configuration file that can be used with the B<--config> switch.

 perl simplebake.pl --gen-config > sample_config.txt

Note that the parameters output with the B<--gen-config> switch are the
defaults used by the script when the user does not supply those options to the
script.

=head1 EXITING SCRIPT

You can send the C<HUP> signal at any time to cause the script to exit.

 kill -HUP <PID of Perl process running script>

The C<Ctrl-C> key combination will also cause the script to exit.

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
