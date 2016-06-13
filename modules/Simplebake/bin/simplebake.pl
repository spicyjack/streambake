#!/usr/bin/perl -w

use strict;
use warnings;

# Copyright (c) 2010, 2013, 2016 by Brian Manning <brian at xaoc dot org>
# PLEASE DO NOT E-MAIL THE AUTHOR ABOUT THIS SCRIPT!
# For help with script errors and feature requests,
# please contact the Streambake mailing list:
# streambake@googlegroups.com / http://groups.google.com/group/streambake

# TODO
# - allow for lines in the playlist with comment characters
# tests
# - incorrect filenames/directories for config files and logfiles
# - missing config file
# - logging to STDOUT and piping logs to a file
#   - fixed below by wrapping IO::Handle around STDOUT and setting autoflush
# - logging to a file in daemon mode
# - reading files from STDIN when using "-" as the filelist filename

=head1 NAME

B<simplebake.pl> - Using a list of MP3/OGG files, stream those files to an
Icecast server.

=head1 VERSION

Version 0.09

=cut

our $VERSION = '0.09';

# a check to verify the shout module is available
# it's put here so some warning is given if --help was called
BEGIN {
   eval { use Shout; };
   if ( $@ ) {
      if ( defined grep(/-h|--help|-j|--gen-config/, @ARGV) ) {
         warn qq(\nWARNING: Shout Perl module is not installed!\n\n);
      } else {
         warn qq( ERR: Shout module not installed\n);
         warn qq( ERR: === Begin error output ===\n\n);
         warn qq($@\n);
         warn qq( ERR: === End error output ===\n);
         die qq(Missing 'Shout' Perl module; exiting...);
      }
   }
}

=head1 SYNOPSIS

 perl simplebake.pl [OPTIONS]

 Script options:
 -v|--verbose     Verbose script execution
 -h|--help        Shows this help text
 -c|--config      Configuration file to use for script options
 -d|--daemon      Fork and run as a daemon; requires --logfile
 -l|--logfile     Logfile to use for script output; default is STDOUT
 -f|--filelist    File containing a list of MP3/OGG files to stream
 -b|--blacklist   List of songs to never play; filters --filelist arg
 -q|--sequential  Play files in sequence instead of randomly
 -t|--throttle    Throttle script this many seconds when missing files
 -q|--sequential  Play songs sequentially (default: shuffle songs)
 --check-songs    Check playlist songs to make sure they can be read
                  Songs are checked when playlist is loaded/reloaded

 Options that generate or check the config:
 -j|--gen-config  Generate a config file containing script defaults
 --check-config   Check the config file given by C<--config> and exit

 Shout module options used by this script:
 -o|--ogg         Set the stream type on the server to Ogg format
 --host           Server hostname or IP address to connect to
 -p|--port        Server port to connect to
 -m|--mount       Mountpoint, where clients connect to on the server
 --nonblocking    Set server connection to be non-blocking
 -a|--password    Server password
 -u|--user        Server username (defaults to 'source')
 -n|--name        Name of the stream (shown along with title metadata)
 -r|--url         URL to the homepage of the stream
 -g|--genre       Genre (used in directory listings on YP servers)
 -s|--description Description of the stream
 -x|--public      Public flag, lists stream on YP servers when set

 Example usage:

 # Generate a config file to modify that contains the script defaults
 simplebake.pl --gen-config

 # Use a configuration file for script options
 simplebake.pl --config /path/to/config/file.cfg

 # Create a stream listenable at http://stream.example.com:8000/somemount
 simplebake.pl --name stream.example.com --port 8000 \
   --mount somemount --filelist /path/to/filelist.m3u \
   --throttle 1

 # Use a blacklist to filter files that won't be played
 simplebake.pl --name stream.example.com --port 8000 \
   --mount somemount --filelist /path/to/filelist.m3u \
   --blacklist /path/to/blacklist.m3u \
   --throttle 1

 # Generate a filelist with this on *NIX platforms
 find /path/to/files -type f -name "*.mp3" \
   > /path/to/output/filelist.txt

Note that the default file type to be streamed with this script is MP3.  If
you want to stream Ogg Vorbis files (*.ogg files), you need to use the
C<--ogg> switch.  You can't mix Ogg and MP3 files in the same stream, as the
server has no way of telling clients that the type of files being streamed has
switched during streaming.

You can set the environment variable C<ICECAST_SOURCE_PASS> with the source
password to the Icecast server, and the script will use that instead of the
source password set elsewhere.

 *NIX signals recognized by the script:
  SIGINT    (aka Ctrl-C) Quits the program
  SIGHUP    Skips the currently playing song
  SIGUSR1   Reloads playlist from disk when --filelist is used

 For example, to skip to the next song in the filelist with:
  kill -HUP <PID of Perl process executing simplebake.pl>

You can view the full C<POD> documentation of this file by calling C<perldoc
simplebake.pl>.

=head1 DESCRIPTION

B<simplebake.pl> is meant to be used as a quick testing script to verify that
all of the correct C libraries and Perl modules needed to stream audio via an
Icecast server are installed, and that all of the Icecast login information
provided to the script is valid.  The script can also be used for as a simple
script for streaming a list of files on a local filesystem.  The script aims
to use as few non-core Perl modules as possible, so that it will run with any
modern (5.8-ish and newer) Perl installation with no extra Perl modules beyond
the L<Shout> module being installed.  L<Shout> requires C<libshout> and
friends to be installed on the system, but most Linux distributions usually
have this packaged.

If throttling is enabled (C<throttle> set to a positive integer),
when the script encounters a file in the filelist that's missing on the
filesystem, the script will wait this many seconds before trying to read
another file.  This is to help prevent the script from running away and
causing a denial of service to other processes on the same machine.  The
default value for throttling is C<throttle = 1> or C<--throttle=1>).  If
C<throttle = 0> is set in the config file or C<--throttle=0> is set on the
command line, the script will B<exit> when a file is missing on the fileystem.

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
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<Simplebake::Config> object, and parses out options using
L<Getopt::Long>.

=cut

# a list of valid arguments that would be used with the Shout module
my @_valid_shout_args
   = qw(host port password mount user name url genre description public);
# a list of valid arguments to this script
my @_valid_script_args = (
   @_valid_shout_args, qw(verbose config logfile filelist blacklist),
   qw(daemon ogg),
   qw(throttle sequential)
);

# a list of arguments that won't cause the script to barf if Shout is not
# installed

sub new {
   my $class = shift;

   my $self = bless ({}, $class);

   # script arguments
   my %args;
   # is the shout module available
   my $shout_available;

   # parse the command line arguments (if any)
   my $parser = Getopt::Long::Parser->new();

   # pass in a reference to the args hash as the first argument
   $parser->getoptions(
      \%args,
      # script options
      q(verbose|v+),
      q(sequential|q),
      q(help|h),
      q(config|c=s),
      q(daemon|d),
      q(logfile|l=s),
      q(filelist|f=s),
      q(blacklist|b=s),
      q(throttle|t=i),
      q(gen-config|j),
      q(check-config),
      q(check-songs),
      # Shout options
      q(ogg|o),
      q(host=s),
      q(port|p=s),
      q(mount|m=s),
      q(nonblocking|b),
      q(password|a=s),
      q(user|u=s),
      q(name|n=s),
      q(url|r=s),
      q(genre|g=s),
      q(description|s=s),
      q(public|x),
   );

   # assign the args hash to this object so it can be reused later on
   $self->{_args} = \%args;

   # dump and bail if we get called with --help
   if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

   # generate a config file and exit?
   if ( $self->defined(q(gen-config)) ) {
      # apply the default configuration options to the Config object
      $self->_apply_defaults();
      # now print out the sample config file
      print qq(# sample simplebake config file\n);
      print qq(# any line that starts with '#' is a comment\n);
      print qq(# sample config generated on )
         . POSIX::strftime( q(%c), localtime() ) . qq(\n);
      foreach my $arg ( @_valid_shout_args ) {
         print $arg . q( = ) . $self->get($arg) . qq(\n);
      } # foreach my $arg ( @_valid_shout_args )
      # cheat a bit and add these last config settings
      # here document syntax
      print <<EOC;
# the path to the list of files to stream
filelist = /path/to/filelist.txt
# list of songs to never play; used as a filter to 'filelist'
blacklist = /path/to/blacklist.txt
# what is the format of the files we're streaming?
# "ogg = 0" == mp3, "ogg = 1" == ogg/vorbis or ogg/flac
ogg = 0
# commenting the logfile will log to STDOUT instead
logfile = /path/to/output.log
# 0 = don't fork, 1 = fork and run in background
daemon = 0
# play files from filelist in sequential order; 0 = random, 1 = sequential
sequential = 0
# throttle delay; set to 0 to exit instead of throttling
throttle = 1
EOC
      exit 0;
   }

   # read a config file if that's specified
   if ( $self->defined(q(config)) && -r $self->get(q(config)) ) {
      open( my $CFG, q(<), $self->get(q(config)) );
      my @config_lines = <$CFG>;
      my $config_errors = 0;
      foreach my $line ( @config_lines ) {
         chomp $line;
         warn qq(VERB: parsing line '$line'\n)
            if ( $self->defined(q(verbose)));
         next if ( $line =~ /^#/ );
         my ($key, $value) = split(/\s*=\s*/, $line);
         warn qq(VERB: key/value for line is '$key'/'$value'\n)
            if ( $self->defined(q(verbose)));
         if ( grep(/$key/, @_valid_script_args) > 0 ) {
            $self->set($key => $value);
         } else {
            warn qq(WARN: unknown config line found in )
               . $self->get(q(config)) . qq(\n);
            warn qq(WARN: unknown config line key/value: $key/$value\n);
            $config_errors++;
         }
      }
      if ( $self->defined(q(check-config)) ) {
         warn qq|Found $config_errors total config error(s)\n|;
         warn qq(Exiting script...\n);
         exit 0;
      }
   }

   # check to see if a source password was set in the environment
   if ( exists $ENV{ICECAST_SOURCE_PASS} ) {
      if ( $self->defined(q(password)) ) {
         if ( $self->defined(q(verbose)) ) {
            warn qq(WARN: password set on command line )
               . qq(and in environment\n);
            warn qq(WARN: using password from environment\n);
         }
         $self->set(key => q(password), value => $ENV{ICECAST_SOURCE_PASS});
      }
   }

   # some checks to make sure we have needed arguments
   die qq( ERR: script called without --config or --filelist arguments;\n)
      . qq( ERR: run script with --help switch for usage examples\n)
      unless ( $self->defined(q(filelist)) );

   # apply script defaults to whatver remaining key/value pairs don't have
   # anything set
   $self->_apply_defaults();

   # return this object to the caller
   return $self;
}

# set defaults here for any missing arugments
sub _apply_defaults {
   my $self = shift;
   # icecast defaults
   $self->set( host => q(localhost) )  unless ( $self->defined(q(host) ) );
   $self->set( port => q(8000) ) unless ( $self->defined(q(port)) );
   $self->set( user => q(source) ) unless ( $self->defined(q(user)) );
   $self->set( mount => q(default) ) unless ( $self->defined(q(mount)) );
   $self->set( name => q(Streambake - simplebake.pl) )
      unless ( $self->defined(q(name)) );
   $self->set( url => q(http://code.google.com/p/streambake/) )
      unless ( $self->defined(q(url)) );
   $self->set( genre => q(mish-mash) )
      unless ( $self->defined(q(genre)) );
   $self->set(
      description => q(I'm too lazy to set a simplebake description) )
      unless ( $self->defined(q(description)) );
   $self->set( public => 0 ) unless ( $self->defined(q(public)) );

   # script defaults
   $self->set( q(ogg) => 0 )
      unless ( $self->defined(q(ogg)) );
   $self->set( q(daemon) => 0 )
      unless ( $self->defined(q(daemon)) );
   $self->set( q(sequential) => 0 )
      unless ( $self->defined(q(sequential)) );
   $self->set( q(throttle) => 1 )
      unless ( $self->defined(q(throttle)) );

   # generate a big fat error message unless we're generating a config file
   if ( ! $self->defined(q(password)) ) {
      if ( ! $self->defined(q(gen-config)) ) {
         warn qq(WARN: using default source password of 'hackme';\n);
         warn qq(WARN: this is probably not what you want;\n);
         warn qq(WARN: set 'ICECAST_SOURCE_PASS' in environment,\n);
         warn qq(WARN: use --password on the command line,\n);
         warn qq(WARN: or set the password in a configuration file\n);
      }
      $self->set( password => q(hackme) );
   }
}

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
   return;
}

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
   }
   return;
}

=item defined($key)

Returns "true" (C<1>) if the value for the key passed in as C<key> is
C<defined>, and "false" (C<0>) if the value is undefined, or the key doesn't
exist.

=cut

sub defined {
   my $self = shift;
   my $key = shift;
   # turn the args reference back into a hash with a copy
   my %args = %{$self->{_args}};

   # Can't use Log4perl here, since it hasn't been set up yet
   if ( exists $args{$key} ) {
      #warn qq(exists: $key\n);
      if ( defined $args{$key} ) {
         #warn qq(defined: $key; ) . $args{$key} . qq(\n);
         return 1;
      }
   }
   return 0;
}

=item get_args( )

Returns a hash containing the parsed script arguments.

=cut

sub get_args {
   my $self = shift;
   # hash-ify the return arguments
   return %{$self->{_args}};
}

=item get_shout_args( )

Returns a hash containing the parsed script arguments.  The hash is filtered
so that it only contains valid arguments for the L<Shout> module.

=cut

sub get_shout_args {
   my $self = shift;

   my %return_args;
   foreach my $key ( @_valid_shout_args ) {
      warn qq(DEBG: key/value = '$key'/') . $self->get($key) . qq('\n)
         if ( $self->defined(q(verbose)) && $self->get(q(verbose)) > 1 );
      $return_args{$key} = $self->get($key);
   }
   return %return_args;
}

=item get_server_connect_string( )

Returns the Icecast connect string for this server connection in a human
readable form (includes the C<http://> prefix).

=cut

sub get_server_connect_string {
   my $self = shift;

   return q(http://) . $self->get(q(host)) . q(:) . $self->get(q(port))
      . q(/) . $self->get(q(mount))
}

=back

=head2 Simplebake::Server

Wraps the L<Shout> module with some defaults that may or may not work.
Actually, the "defaults" most likely won't work.

=head3 Object Methods

=cut

######################
# Simplebake::Server #
######################
package Simplebake::Server;
use strict;
use warnings;

# constants swiped from shout.h; yes, hardcoding them is bad, but this lets
# the below eval() test work instead of the script dying because of the SHOUT
# barewords that were being used by this object
use constant {
   SB_FORMAT_OGG => 0,
   SB_FORMAT_MP3 => 1,
   SB_PROTOCOL_HTTP => 0,
   SB_PROTOCOL_XAUDIOCAST => 1,
   SB_PROTOCOL_ICY => 2,
};

=over

=item new(config => $config, logger => $logger)

Creates the L<Simplebake::Server> object, and populates it with default values
if no C<%args> hash is passed into it.  Returns the object that is created.

=cut

sub new {
   my $class = shift;
   my %args = @_;

   # pull the arguments hash and the logger object from the arguments to this
   # method
   my $config = $args{config};
   my $logger = $args{logger};

   # create a copy of the args hash, then sanitize it prior to passing it
   # into Shout
   my %shoutargs = $config->get_shout_args();
   # we should have things set up enough now to be able to create the Shout
   # object
   my $conn = Shout->new(%shoutargs);
   die qq( ERR: could not create Shout object: $!) unless ( defined $conn );
   # set some other misc settings
   # see note above about the definition/copying of the constants from
   # shout.h
   if ( $config->get(q(ogg)) == 1 ) {
      $conn->format(SB_FORMAT_OGG);
   } else {
      $conn->format(SB_FORMAT_MP3);
   }
   $conn->protocol(SB_PROTOCOL_HTTP);
   $conn->set_audio_info(
      SHOUT_AI_BITRATE => 256,
      SHOUT_AI_SAMPLERATE => 44100,
   );

   # add the connection object to the attributes of this object
   # bless this class into an object
   my $self = bless ({
      _conn   => $conn,
      _logger => $logger,
      _config => $config,
   }, $class);
   # return this object to the caller
   return $self;
}

=item open( )

Calls the C<open()> method of the L<Shout> module.  Returns C<1> upon success,
or dies and returns the error message if the C<open()> call fails.

=cut

sub open {
   my $self = shift;
   my $conn = $self->{_conn};
   my $logger =  $self->{_logger};

   unless ( $conn->open() ) {;
      $logger->timelog(q( ERR: Failed to open connection: )
         . $conn->get_error());
      exit 1;
   }

   return 1;
}

=item close( )

Calls the C<close()> method of the L<Shout> module.  Returns C<1> upon
success, or dies and returns the error message if the C<close()> call fails.

=cut

sub close {
   my $self = shift;
   my $conn = $self->{_conn};

   my $logger =  $self->{_logger};

   unless ( $conn->close() ) {;
      $logger->timelog(q( ERR: Failed to close connection: )
         . $conn->get_error());
      exit 1;
   }

   return 1;
}

=item set_metadata( song => $metadata )

Sets the stream metadata on the Icecast server to C<$metadata>.  Returns
C<true> if the call succeeds, or C<undef> if the call fails.

=cut

sub set_metadata {
   my $self = shift;
   my @args = @_;
   my $conn = $self->{_conn};

   # return success if we can set the metadata
   return 1 if ( $conn->set_metadata(@args) );
   # return failure if something went wrong
   return;
}

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
   my $logger =  $self->{_logger};

   # we always need the data to be sent; the length is optional, Shout.pm
   # computes it if it's missing.
   if ( ! exists $args{data} ) {
      die q| ERR: send() called without 'data' argument|;
   }

   # die if something went wrong
   if ( exists $args{length} ) {
      unless ( $conn->send($args{data}, $args{length}) ) {
         $logger->timelog(q( ERR: Failed to send data: )
            . $conn->get_error());
         exit 1;
      }
   } else {
      unless ( $conn->send($args{data}) ) {
         $logger->timelog(q( ERR: Failed to send data: )
            . $conn->get_error());
         exit 1;
      }
   }
   return 1;
}

=item sync( )

Sleep until the connection is ready for more data; blocks until the server is
ready for more data.  Always returns a true value.

=cut

sub sync {
   my $self = shift;
   my $conn = $self->{_conn};

   $conn->sync();
   return 1;
}

=item get_error( )

Return the text error message returned if the last server operation failed.

=cut

sub get_error {
   my $self = shift;
   my $conn = $self->{_conn};

   return $conn->get_error();
}

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
use IO::File;
use IO::Handle;

=over

=item new($config)

Creates the L<Simplebake::Logger> object, and sets up various filehandles
needed to log to files or C<STDOUT>.  Requires a L<Simplebake::Config> object
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
   }
   $logfd->autoflush(1);

   my $self = bless ({
      _OUTFH => $logfd,
   }, $class);

   # return this object to the caller
   return $self;
}

=item log($message)

Log C<$message> to the logfile, or I<STDOUT> if the B<--logfile> option was
not used.

=cut

sub log {
   my $self = shift;
   my $msg = shift;

   my $FH = $self->{_OUTFH};
   print $FH $msg . qq(\n);
}

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
}

=back

=head2 Simplebake::Playlist

Holds a list of songs to stream.  The main script will query this object for
songs to stream, and also will also send this object signals to reload the
playlist from disk when a playlist file is used (as opposed to piping the
playlist in to the script on STDIN).

=head3 Object Methods

=cut

########################
# Simplebake::Playlist #
########################
package Simplebake::Playlist;
use strict;
use warnings;

use constant {
   THROTTLE_MAX_COUNT => 3,
   THROTTLE_CHECK_TIME => 3,
};

my (@_blacklist, @_playlist, @_song_q);
my $_last_request_time = 0;
my $_throttle_counter = 0;

=over

=item new(config => $config, logger => $logger)

Creates the L<Simplebake::Playlist> object, reads the playlist file from disk
or from C<STDIN>.  Returns the playlist object to the caller.

=cut

sub new {
   my $class = shift;
   my %args = @_;

   my ($config, $logger);
   if ( exists $args{config} ) {
      $config = $args{config};
   } else {
      die qq( ERR: Simplebake::Config object required as 'config =>');
   }

   if ( exists $args{logger} ) {
      $logger = $args{logger};
   } else {
      die qq( ERR: Simplebake::Logger object required as 'logger =>');
   }

   my $self = bless ({
      # save the config and logger objects so that this object's methods can
      # use them
      _logger => $logger,
      _config => $config,
   }, $class);

   return $self
}

=item load_playlist( )

Loads the playlist from a file if the C<--filelist> parameter was used when
the script was started.  If the playlist was read via C<STDIN>, nothing is
read.  This method then reloads the song queue from the playlist.

=cut

sub load_playlist {
   my $self = shift;

   # copy the playlist object to a local name
   my $config = $self->{_config};
   my $logger = $self->{_logger};

   # verify the playlist file can be opened and then read it
   if ( defined $config->get(q(filelist)) ) {
      # read from STDIN, but only if we've never read from STDIN before
      if ( $config->get(q(filelist)) eq q(-) ) {
         # read files from STDIN
         if (scalar(@_playlist) == 0) {
            # set UTF-8 encoding on STDIN before you read it
            # binmode(STDIN, qq|:encoding(utf8)|);
            # nothing in the playlist yet, do the actual read
            @_playlist = <STDIN>;
         } else {
            # we've already read from STDIN, don't do it again; give
            # a nice warning to the user though
            $logger->timelog(qq(WARN: Can't reload playlist from STDIN));
            return;
         }
      # read from a filelist somewhere?
      } elsif ( -r $config->get(q(filelist)) ) {
         # open the filelist using an IO::File object
         my $plfd = IO::File->new(q( < ) . $config->get(q(filelist)));
         die q( ERR: could not open ) . $config->get(q(filelist))
            unless ( defined $plfd );
         # apply UTF-8-ness to the filehandle
         #$plfd->binmode(qq|:encoding(utf8)|);
         # same as @_playlist = <FH>;
         @_playlist = $plfd->getlines();
         $plfd->close();
         undef $plfd;
      # nope; bail!
      } else {
         die q( ERR: Filelist ) . $config->get(q(filelist))
            . q( does not exist or is not readable);
      }
   } else {
      die q( ERR: no --filelist argument specified; See --help for options);
   }

   # remove trailing newlines
   chomp(@_playlist);
   $logger->timelog(qq(INFO: Read ) . scalar(@_playlist)
      . q( items from playlist file));

   # check the files in the playlist before trying to play them
   if ( $config->get(q(check-songs)) ) {
      my @checked_playlist;
      foreach my $song (@_playlist) {
         if ( -r $song  ) {
            if ( -f $song ) {
               push(@checked_playlist, $song);
            } else {
               $logger->timelog(qq(WARN: File $song is not a file));
            }
         } else {
            $logger->timelog(qq(WARN: File $song is not readable));
         }
      }
      @_playlist = @checked_playlist;
   }

   # verify the blacklist file can be opened and then read it
   if ( defined $config->get(q(blacklist)) ) {
      if ( -r $config->get(q(blacklist)) ) {
         # open the filelist using an IO::File object
         my $blfd = IO::File->new(q( < ) . $config->get(q(blacklist)));
         die q( ERR: could not open ) . $config->get(q(blacklist))
            unless ( defined $blfd );
         # apply UTF-8-ness to the filehandle
         #$blfd->binmode(qq|:encoding(utf8)|);
         # same as @_playlist = <FH>;
         @_blacklist = $blfd->getlines();
         $blfd->close();
         undef $blfd;
      } else {
         die q( ERR: Blacklist file ) . $config->get(q(blacklist))
            . q( does not exist, or is not readable);
      }
   }

   # remove trailing newlines from blacklist
   chomp(@_blacklist);
   $logger->timelog(qq(INFO: Read ) . scalar(@_blacklist)
      . q( items from blacklist file));

   # filter the playlist through the blacklist
   my %playlist = map( { $_ => 1 } @_playlist);
   my %blacklist = map( { $_ => 1 } @_blacklist);

   foreach my $key ( keys(%blacklist) ) {
      if ( exists ( $playlist{$key} ) ) {
         delete $playlist{$key};
      } else {
         $logger->timelog(q(WARN: file in blacklist not in playlist));
         $logger->timelog(qq(WARN: blacklist file: $key));
      }
   }
   # reassign the playlist from the results of filtering files
   @_playlist = keys(%playlist);

   # make a copy of the playlist before we start munging it
   $logger->timelog(qq(INFO: Playlist contains ) . scalar(@_playlist)
      . q( songs));

   # copy the contents of the playlist to the song_q
   @_song_q = @_playlist;
   return 1;
}

=item get_song( )

Retrieves a song from the song queue and returns it as a L<Simplebake::File>
object.  The song queue will automagically reload itself when it becomes
empty.

=cut

sub get_song {
   my $self = shift;

   # grab a copy of the logger and config objects
   my $logger = $self->{_logger};
   my $config = $self->{_config};
   my $current_time = time();

   my $next_song;
   SONG_LOOP: while ( ! defined $next_song ) {
      # check whether or not we need to throttle
      if ( ( $_last_request_time + THROTTLE_CHECK_TIME ) >= $current_time ) {
         $_throttle_counter++;
         if ( $_throttle_counter > THROTTLE_MAX_COUNT ) {
            $logger->timelog(qq(WARN: Throttling triggered!));
            $logger->timelog(qq(WARN: Is the playlist valid/readable?));
            sleep( $config->get(q(throttle)) );
         }
      } else {
         # decrement the counter if we're good on time now
         if ( $_throttle_counter > 0 ) { $_throttle_counter--; }
      } # if ( ( $_last_request_time + $config->get(q(throttle_time)) )

      # housekeeping for --throttle mode
      $_last_request_time = $current_time;

      # check to see if the song_q is empty
      if ( scalar(@_song_q) == 0 ) {
         $logger->timelog(qq(INFO: Reloading song queue));
         @_song_q = @_playlist;
      } # if ( scalar(@song_q) == 0 )

      # figure out what the next song will be;
      # play songs in the same sequence as they appear in the filelist, or
      # play them in sequence from the top of the file to the bottom?
      if ( $config->get(q(sequential)) ) {
         $next_song = shift(@_song_q);
      } else {
         my $random_song = int( rand($self->get_song_q_count()) );
         # splice it out of the song_q array
         $next_song = splice(@_song_q, $random_song, 1);
      }

      # verify we can read the song before returning it
      if ( defined $next_song ) {
         if ( ! -r $next_song ) {
            $logger->timelog(qq(WARN: File $next_song is not readable!));
            undef $next_song;
            next SONG_LOOP;
         }
         # check to see if $next_song is a file; if not, set it to undef so
         # this loop gets run again; either a file will eventually be
         # found, or the throttle will kick in
         if ( ! -f $next_song ) {
            $logger->timelog(qq(WARN: $next_song is not a file!));
            undef $next_song;
         }
      }
   }

   # create a Simplebake::File object
   my $song_obj = Simplebake::File->new(
      streamfile => $next_song,
      logger => $logger,
      config => $config,
   );

   if ( defined $song_obj ) {
      $logger->timelog(qq(INFO: Returning new song )
         . $song_obj->get_filename() )
         if ( defined $config->get(q(verbose)));
   }

   # return the current song (filename) to the caller
   return $song_obj;
}

=item get_song_q_count( )

Returns the number of songs left in the song queue.

=cut

sub get_song_q_count {
   my $self = shift;

   # grab the logger object
   my $logger = $self->{_logger};

   $logger->timelog(q(INFO: song_q status));
   my $song_q_count = scalar(@_song_q);
   if ( $song_q_count == 1 ) {
      $logger->log(q(- 1 song currently in the song_q));
   } else {
      $logger->log(qq(- $song_q_count songs currently in the song_q));
   }
   return $song_q_count;
}

=back

=head2 Simplebake::File

An object that represents the file that is to be streamed to the
Icecast/Shoutcast server.  This is a helper object for the file that helps out
different functions related to file metadata and logging output.  Returns
C<undef> if the file doesn't exist on the filesystem or can't be read.

=head3 Object Methods

=cut

####################
# Simplebake::File #
####################
package Simplebake::File;
use strict;
use warnings;

=over

=item new(streamfile => $file, logger => $logger, config => $config)

Creates an object that wraps the file to be streamed, so that requests for
file metadata can be answered.

=cut

sub new {
   my $class = shift;
   my %args = @_;

   my ($streamfile, $logger, $config);
   die qq( ERR: Missing file to be streamed as 'streamfile =>')
      unless ( exists $args{streamfile} );
   $streamfile = $args{streamfile};

   die qq( ERR: Simplebake::Logger object required as 'logger =>')
      unless ( exists $args{logger} );
   $logger = $args{logger};

   die qq( ERR: Simplebake::Logger object required as 'logger =>')
      unless ( exists $args{config} );
   $config = $args{config};

   my $self = bless ({
      # save the config and logger objects so that this object's methods can
      # use them
      _logger => $logger,
      _config => $config,
      _streamfile => $streamfile,
      _track_name => q(),
      _album_name => q(),
      _artist_name => q(),
   }, $class);

   # some tests of the actual file on the filesystem
   # does it exist?
   unless ( -e $self->get_filename() ) {
      $logger->timelog( qq(WARN: Missing file on filesystem!) );
      $logger->log(qq(- ) . $self->get_display_name() );
      # return an undefined object so that callers know something's wrong
      return;
   }

   # can we read the file?
   unless ( -r $self->get_filename() ) {
      $logger->timelog( qq(WARN: Can't read file on filesystem!) );
      $logger->log(qq(- ) . $self->get_display_name() );
      # return an undefined object so that callers know something's wrong
      return;
   }

   # do some of the cutty-up bits here
   # get the name of the file for metadata
   my @song_metadata = split(q(/), $self->get_filename() );
   # generate the metadata items using the song's filename
   if ( defined $song_metadata[-1] ) {
      $self->{_track_name} = $song_metadata[-1];
      # remove the file extension from the track name
      $self->{_track_name} =~ s/\.mp3$|\.ogg$//;
      # remove leading numbers with dashes from the track name
      if ( $self->{_track_name} =~ /^\d+-/ ) {
         $self->{_track_name} =~ s/^\d+-//;
      }
      # remove leading numbers with spaces from the trackname
      if ( $self->{_track_name} =~ /^\d+ / ) {
         $self->{_track_name} =~ s/^\d+ //;
      }
   }
   if ( defined $song_metadata[-2] ) {
      $self->{_album_name} = $song_metadata[-2];
   }
   if ( defined $song_metadata[-3] ) {
      $self->{_artist_name} = $song_metadata[-3];
   }

   return $self
}

=item get_filename()

Returns the full filename of the file to be streamed.

=cut

sub get_filename {
   my $self = shift;
   return $self->{_streamfile};
}

=item get_track_name()

Returns the track name as determined by the filename of the file that is being
streamed.

=cut

sub get_track_name {
   my $self = shift;
   return $self->{_track_name};
}

=item get_album_name()

Returns the album name as determined by the filename of the file that is being
streamed.

=cut

sub get_album_name {
   my $self = shift;
   return $self->{_album_name};
}

=item get_artist_name()

Returns the artist name as determined by the filename of the file that is
being streamed.

=cut

sub get_artist_name {
   my $self = shift;
   return $self->{_artist_name};
}

=item get_display_name()

Returns the filename, truncated to 60 characters (with an ellipsis in front)
so it fits nicely when log output is going to a terminal.

=cut

sub get_display_name {
   my $self = shift;
   my $song = $self->get_filename();
   my $display_song; # the returned filename

   if ( length($song) > 60 ) {
      $display_song = q(...) . substr($song, -60);
   } else {
      $display_song = $song;
   }
}

=back

=cut

################
# package main #
################
package main;
use strict;
use warnings;
use English;

#use bytes; # I think this is used for the sysread call when reading MP3 files

   # skip the current song?
   my $skip_current_song = undef;
   # create a logger object
   my $config = Simplebake::Config->new();

   # fork into the background and run as a daemon if requested
   # note that we're comparing a string here, not an integer; this way, the
   # user can put just about anything in there (string or number) and things
   # will Just Work
   if ( defined $config->get(q(daemon)) && $config->get(q(daemon)) != q(0) ) {
      # if we want to "properly" background, we should be writing output to
      # a logfile
      if ( defined $config->get(q(logfile)) ) {
         my $pid = fork();
         if ( defined $pid ) {
            # parent, which exits
            if ( $pid > 0 ) {
               warn qq(INFO: Fork; parent PID $$ is exiting...\n);
               exit 0;
            # child, which continues
            } else {
               warn qq(INFO: Fork; child PID is $$\n);
            }
         } else {
            die qq( ERR: Forking failed: $!\n);
         }
      } else {
         die qq( ERR: --daemon requires --logfile; see --help\n);
      }
   }

   # create a logger object, and prime the logfile for this session
   my $logger = Simplebake::Logger->new($config);
   $logger->timelog(qq(INFO: Starting simplebake.pl, version $VERSION));
   $logger->timelog(qq(INFO: my PID is $$));
   # assign to $PROGRAM_NAME, which should change the program string
   # displayed in [top|ps|etc.]
   $PROGRAM_NAME = q(perl: simplebake.pl -c ) . $config->get(q(config));

   my $playlist = Simplebake::Playlist->new(
      config  => $config,
      logger  => $logger,
   );
   # initialize the playlist and song_q
   $playlist->load_playlist();

   my $conn = Simplebake::Server->new(
      config  => $config,
      logger  => $logger,
   );

   # hopefully this should catch when the Shout module is not installed
   die qq( ERR: Could not create Shout object\n) unless ( defined $conn );

   # reroute some signals to our handlers
   # exiting the script
   $SIG{INT} = $SIG{TERM} = sub {
      my $signal = shift;
      $logger->timelog(qq(CRIT: Received SIG$signal; exiting...));
      # close the connection to the icecast server
      $conn->close();
   };

   # skipping songs
   $SIG{HUP} = sub {
      $skip_current_song = 1;
      $logger->timelog(qq(INFO: Received SIGHUP; skipping current song));
   };

   # reloading the playlist when an actual file is used (as opposed to STDIN)
   $SIG{USR1} = sub {
      $logger->timelog(qq(INFO: Received SIGUSR1; reloading playlist));
      $playlist->load_playlist();
   };

   # try to connect to the icecast server
   if ( $conn->open() ) {
      $logger->timelog(q(INFO: Connected to server));
      $logger->log(q(- server URL: ) . $config->get_server_connect_string() );
      $logger->log(q(- source user: ') . $config->get(q(user)) . q('));
      if ( $config->get(q(ogg)) == 1 ) {
         $logger->log(q(- setting stream format on server to: OGG));
      } else {
         $logger->log(q(- setting stream format on server to: MP3));
      }

      # endless loop
      ENDLESS: while ( 1 ) {
         # grab a song from the playlist
         my $song = $playlist->get_song();
         # if the Simplebake::File object is not created for whatever
         # reason, go ahead and skip to the next song
         next unless ( defined $song );

         $logger->timelog(q(INFO: Begin streaming new file));
         $logger->log(qq(- Filename: ) . $song->get_display_name() );
         $logger->log(q(- Server URL: )
            . $config->get_server_connect_string() );

         # buffer for holding data read from the file
         my $buff;
         # open the file
         $logger->log(qq(- Opening file for streaming));

         # XXX external re-encoding
         #open($STREAMFILE, q(/bin/cat ") . $song->get_filename()
         #   . q(" | lame --quiet -V 4 --mp3input - - |) )
         #   || die qq(Can't open ) . $song->get_filename() . qq( : '$!');
         open(my $STREAMFILE, q(<),  $song->get_filename() )
            || die qq(Can't open ) . $song->get_filename()
            . q( : '$!');
         # used for the while loop below
         my $file_open_flag = 1;
         # treat $STREAMFILE as binary data
         binmode($STREAMFILE);

         # update the metadata
         $logger->log(qq(- Updating metadata on server));
         $conn->set_metadata( song =>
            $song->get_artist_name() . q( - )
            . $song->get_album_name() . q( - )
            . $song->get_track_name() );
         $logger->log(qq(- Streaming file to server));

         while ( $file_open_flag ) {
         #while (defined(sysread($STREAMFILE, $buff, 4096) > 0)) {
            # check before each sysread() to see if the user veto'ed this
            # song
            if ( defined $skip_current_song ) {
               # this event is logged in the HUP handler
               $skip_current_song = undef;
               $logger->timelog(qq|- Skipping current song...|);
               close($STREAMFILE);
               next ENDLESS;
            }
            # sysread returns undef if there's an error; capture and log
            # it
            my $bytes_read = sysread($STREAMFILE, $buff, 4096);
            if ( ! defined $bytes_read ) {
               $logger->timelog(qq|- WARN: sysread() returned 'undef'|);
               $logger->log(qq|- sysread() error: $!|);
               # skip to the next song
               next ENDLESS;
            } elsif ( $bytes_read == 0 ) {
               $logger->timelog(qq|- End of file|);
               # skip to the next song
               next ENDLESS;
            } else {
               $logger->log(qq(- Read a block of data...))
                  if ( defined $config->get(q(verbose)) &&
                     $config->get(q(verbose)) > 1);
            }

            # send a block of data, and error out if it fails
            $logger->log(qq(- Sending block of data...))
               if ( defined $config->get(q(verbose)) &&
                  $config->get(q(verbose)) > 1);
            unless ( $conn->send(data => $buff, length => length($buff)) ) {
               $logger->timelog(q( ERR: while sending buffer to server:));
               $logger->timelog(q( ERR:) . $conn->get_error);
               $conn->sync;
               last ENDLESS;
            }
            # must be careful not to send the data too fast :)
            $conn->sync;
         }
         # close the file now that we've read it
         $logger->timelog(qq(INFO: Closing file));
         #$logger->log(qq(- $display_song));
         close($STREAMFILE);
      }
      $logger->timelog(qq(WARN: server closed connection; exiting...));
      die q(we died here :/);
   } else {
      $logger->timelog(qq(WARN: couldn't connect to server; ));
      $logger->timelog(q(WARN: ) . $conn->get_error());
   }

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

You can use the B<--gen-config> command line switch to generate a
configuration file that can be used with the B<--config> switch.

 perl simplebake.pl --gen-config > sample_config.txt

Note that the parameters output with the B<--gen-config> switch are the
defaults used by the script when the user does not supply those options to the
script.

=head1 UNIX SIGNALS

=over 4

=item SIGINT

You can send the C<INT> signal at any time to cause the script to exit.

 kill -INT <PID of Perl process running script>

The C<Ctrl-C> key combination will also cause the script to exit if the script
is running in the foreground (C<daemon = 0>).

=item SIGHUP

Sending a C<SIGHUP> to the Perl process running this script will cause the
script to skip the currently playing song.

=item SIGUSR1

Sending a C<SIGUSR1> will cause the script to reload the playlist from disk if
the C<--filelist> option was used on the command line or C<filelist =
/path/to/some/file.txt> in a config file.  This signal is ignored when the
playlist is read from C<STDIN>.

=back

=head1 AUTHOR

Brian Manning, C<< <brian at xaoc dot org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<< <streambake at googlegroups dot com> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

   perldoc simplebake.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008,2010,2012 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set sw=4 ts=4
