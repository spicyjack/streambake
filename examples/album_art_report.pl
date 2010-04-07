#!/usr/bin/perl -w

# Copyright (c) 2010 by Brian Manning <elspicyjack at gmail dot com>
# PLEASE DO NOT E-MAIL THE AUTHOR ABOUT THIS SCRIPT!
# For help with script errors and feature requests, 
# please contact the Streambake mailing list:
# streambake@googlegroups.com / http://groups.google.com/group/streambake

=head1 NAME

B<album_art_report.pl> - Given a directory, report on the different
files found that could contain metadata, and of the ones that contain
metadata, how many contain images (JPEG, PNG, GIF) versus how many files don't
contain images.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 perl album_art_report.pl [OPTIONS]

 Script options:
 -v|--verbose       Verbose script execution
 -h|--help          Shows this help text
 -p|--path          Configuration file to use for script options
 -s|--summary       Summarize information for each directory, don't show
                    individual file information  

 Example usage:

 # Generate a list of files that don't have album art
 album_art_report.pl --verbose --path /path/to/audio/files

 # Use a configuration file for script options
 album_art_report.pl --config /path/to/config/file.cfg

You can view the full C<POD> documentation of this file by calling C<perldoc
album_art_report.pl>.

=head1 DESCRIPTION

B<album_art_report.pl> is a script that reports on album art in media
files.

=head1 OBJECTS

=head2 AlbumArtReport::Config

An object used for storing configuration data.

=head3 Object Methods

=cut 

######################
# AlbumArtReport::Config #
######################
package AlbumArtReport::Config;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<AlbumArtReport::Config> object, and parses out options using
L<Getopt::Long>.

=cut

# a list of valid arguments to this script
my @_valid_script_args = ( qw(verbose config) );
); # my @_valid_script_args 

# a list of arguments that won't cause the script to barf if Shout is not
# installed

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
        q(verbose|v+),
        q(help|h),
        q(config|c=s),
        # list what file types the script understands, then exit
        q(list|l),
        q(summary|s),
        # other options
        # show files with ID3v1 or ID3v2 tags
        q(id3v1|1),
        q(id3v2|2),
        # ѕhow ogg, flac, or mp3 files
        q(ogg|o),
        q(flac|f),
        q(mp3|m),
    ); # $parser->getoptions

    # assign the args hash to this object so it can be reused later on
    $self->{_args} = \%args;

    # a check to verify the shout module is available
    # it's put here so some warning is given if --help was called

=begin comment

    BEGIN {
        eval q( use Shout; );
        if ( $@ ) {
            if ( defined grep(/-h|--help|-j|--gen-config/, @ARGV) ) {
                warn qq(\nWARNING: Shout Perl module is not installed!\n\n);
            } else {
                warn qq( ERR: Shout module not installed\n);
                warn qq( ERR: === Begin error output ===\n\n);
                warn qq($@\n);
                warn qq( ERR: === End error output ===\n);
                die qq(Missing 'Shout' Perl module; exiting...);
            } # if ( $self->get(q(help)) )
        } # if ( $@ )
    } # BEGIN

=end comment

=cut

    # dump and bail if we get called with --help
    if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

    # return this object to the caller
    return $self;
} # sub new

=item get($key)

Returns the scalar value of the key passed in as C<key>, or C<undef> if the
key does not exist in the L<AlbumArtReport::Config> object.

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

Sets in the L<AlbumArtReport::Config> object the key/value pair passed in as
arguments.  Returns the old value if the key already existed in the
L<AlbumArtReport::Config> object, or C<undef> otherwise.

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

=head2 AlbumArtReport::Logger

A simple logger module, for logging script output and errors.

=head3 Object Methods

=cut

######################
# AlbumArtReport::Logger #
######################
package AlbumArtReport::Logger;
use strict;
use warnings;
use POSIX qw(strftime);
use IO::File;
use IO::Handle;

=over 

=item new($config)

Creates the L<AlbumArtReport::Logger> object, and sets up various filehandles
needed to log to files or C<STDOUT>.  Requires a L<AlbumArtReport::Config> object
as the argument, so that options having to deal with logging can be
parsed/acted upon.  Returns the logger object to the caller.

=cut

sub new {
    my $class = shift;
    my $config = shift;

    my $logfd;
    if ( defined $config->get(q(logfile)) ) {
        # append to the existing logfile, if any
        $logfd = IO::File->new(q( >> ) . $config->get(q(logfile)));
        die q( ERR: Can't open logfile ) . $config->get(q(logfile)) . qq(: $!)
            unless ( defined $logfd );
        # apply UTF-8-ness to the filehandle 
        $logfd->binmode(qq|:encoding(utf8)|);
    } else {
        # set :utf8 on STDOUT before wrapping it in IO::Handle
        binmode(STDOUT, qq|:encoding(utf8)|);
        $logfd = IO::Handle->new_from_fd(fileno(STDOUT), q(w));
        die qq( ERR: could not wrap STDOUT in IO::Handle object: $!) 
            unless ( defined $logfd );
    } # if ( exists $args{logfile} )
    $logfd->autoflush(1);

    my $self = bless ({
        _OUTFH => $logfd,
    }, $class);

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

=head2 AlbumArtReport::File

An object that represents the file that is to be streamed to the
Icecast/Shoutcast server.  This is a helper object for the file that helps out
different functions related to file metadata and logging output.  Returns
C<undef> if the file doesn't exist on the filesystem or can't be read.

=head3 Object Methods

=cut

####################
# AlbumArtReport::File #
####################
package AlbumArtReport::File;
use strict;
use warnings;

=over 

=item new(filename => $file, logger => $logger, config => $config)

Creates an object that wraps the file to be streamed, so that requests for
file metadata can be answered.

=cut

sub new {
    my $class = shift;
    my %args = @_;

    my ($filename, $logger, $config);
    die qq( ERR: Missing file to be streamed as 'filename =>')
        unless ( exists $args{filename} );
    $filename = $args{filename};

    die qq( ERR: AlbumArtReport::Logger object required as 'logger =>')
        unless ( exists $args{logger} );
    $logger = $args{logger};
        
    die qq( ERR: AlbumArtReport::Logger object required as 'logger =>')
        unless ( exists $args{config} );
    $config = $args{config};

    my $self = bless ({
        # save the config and logger objects so that this object's methods can
        # use them
        _logger => $logger,
        _config => $config,
        _filename => $filename,
    }, $class);

    # some tests of the actual file on the filesystem
    # does it exist?
    unless ( -e $self->get_filename() ) { 
        $logger->timelog( qq(WARN: Missing file on filesystem!) );
        $logger->log(qq(- ) . $self->get_display_name() );
        # return an undefined object so that callers know something's wrong
        undef $self;
    } # unless ( -e $self->get_filename() )

    # previous step may have set $self to undef
    if ( defined $self ) {
        # can we read the file?
        unless ( -r $self->get_filename() ) { 
            $logger->timelog( qq(WARN: Can't read file on filesystem!) );
            $logger->log(qq(- ) . $self->get_display_name() );
            # return an undefined object so that callers know something's wrong
            undef $self;
        } # unless ( -r $self->get_filename() )
    } # if ( defined $self )

    return $self
} # sub new

=back

=cut

################
# package main #
################
package main;
use strict;
use warnings;

#use bytes; # I think this is used for the sysread call when reading MP3 files

    # create a logger object
    my $config = AlbumArtReport::Config->new();

    # create a logger object, and prime the logfile for this session
    my $logger = AlbumArtReport::Logger->new($config);
    $logger->timelog(qq(INFO: Starting album_art_report.pl, version $VERSION));
    $logger->timelog(qq(INFO: my PID is $$));

    # reroute some signals to our handlers
    # exiting the script
    $SIG{INT} = $SIG{TERM} = sub { 
        my $signal = shift;
        $logger->timelog(qq(CRIT: Received SIG$signal; exiting...));
        # close the connection to the icecast server
        $conn->close();
    }; # $SIG{INT}

    $SIG{HUP} = sub { 
        $logger->timelog(qq(INFO: Received SIGHUP;));
    }; # $SIG{HUP}

    $SIG{USR1} = sub { 
        $logger->timelog(qq(INFO: Received SIGUSR1;));
    }; # $SIG{USR1}

=head1 AUTHOR

Brian Manning, C<< <elspicyjack at gmail dot com> >>

=head1 BUGS

Please report any bugs or feature requests to 
C<< <streambake at googlegroups dot com> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc album_art_report.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008,2010 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set sw=4 ts=4
