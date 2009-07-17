#!/usr/bin/env perl

# $Id$
# $Author$
# *DO NOT* contact the author of the software for support.
# For support, please visit the Streambake homepage/mailing list at:
# http://groups.google.com/group/streambake or <streambake@googlegroups.com>

# License terms at the bottom of this file

# pragmas
use strict;
use warnings;
# modules
use Getopt::Long;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
# 5.817 is the first release without RC_ in front of all of the HTTP constants
use HTTP::Status 5.817 qw(:constants);
use Log::Log4perl qw(get_logger);
use Log::Log4perl::Level;
use Pod::Usage;

my ($VERBOSE, $discid, $colorlog, $indir, $outdir);
# colorize Log4perl output by default 
$colorlog = 1;

my $go = Getopt::Long::Parser->new();
$go->getoptions(   
    q(verbose|v)                    => \$VERBOSE,
    q(help|h)                       => \&ShowHelp,
    q(discid|di|d=s)                => \$discid,
    q(input-dir|indir|in|i=s)       => \$outdir,
    q(output-dir|outdir|out|o=s)    => \$indir,
    q(colorlog!)                    => \$colorlog,
); # $goparse->getoptions

# create the object

# give it a pretty name
my $version = q(Streambake 0.01);

my $cddb_url = q(http://freedb.freedb.org/~cddb/cddb.cgi);
my $get_url = qq($cddb_url?cmd=cddb+query+03015501+1+296+344);

fetch_url($get_url, $version);

# track offsets of all of the tracks from 2-*, followed by the disc length in
# frames
my $disc_offset = 150;
my $disc_id = q(980ae90b);
my @bare_tracks = ( 
    20642, 35837, 50880, 73630, 92845, 108662, 
    130742, 143110, 172655, 186887, 209492
);
my @offset_tracks;
my $freedb_tracks;
foreach my $track ( @bare_tracks ) {
    push(@offset_tracks, $track + $disc_offset);
} # foreach my $track ( @bare_tracks )

$get_url = qq($cddb_url?cmd=cddb+query+$disc_id+);
my $disc_length = pop(@offset_tracks);
my $disc_seconds = int($disc_length / 75);

$get_url = $get_url . (scalar(@offset_tracks) + 1) . qq(+$disc_offset+) 
    . join(q(+), @offset_tracks) . qq(+$disc_seconds);

fetch_url($get_url, $version);

exit 0;

sub fetch_url {
    my $url = shift;
    my $cgi_version = shift;

    $cgi_version =~ s/ /+/;
    $url .= qq(&hello=user+example.com+$cgi_version&proto=4);
    my $ua = LWP::UserAgent->new();
    $ua->agent( $version . q(;) . $ua->agent() );
    print qq(URL is:\n$url\n);
    my $req = HTTP::Request->new( GET => $url );
    my $resp = $ua->request($req);
    if ( $resp->code() == HTTP_OK ) {
        print q(HTTP 200 -> CDDBP ) . $resp->decoded_content();
    } elsif ( $resp->code() == HTTP_INTERNAL_SERVER_ERROR ) {
        print q(HTTP 500 -> CDDBP ) . $resp->status_line. qq(\n);
    } else {
        print q(ERROR: an unknown error occured; ) . $resp->code();
    } # if ( $resp->code() = HTTP_OK )

} # sub fetch_url

### BEGIN LICENSE TERMS ###
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# vi: set sw=4 ts=4:
# end of line
