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
our $VERSION = q(0.01);


my $get_url = qq(cmd=cddb+query+03015501+1+296+344);
my $disc_id = q(03015501);
# leadout is the location of the last bit of data
my $leadout = 344;
# list of starting points for tracks
my @bare_tracks = (146);

fetch_url($get_url, $VERSION);

# QOTSA - QOTSA
# CDDB disc ID computed with an external program
$disc_id = q(980ae90b);
$leadout = 209492;
@bare_tracks = ( 
    20642, 35837, 50880, 73630, 92845, 108662, 
    130742, 143110, 172655, 186887
);
fetch_url(create_freedb_query($disc_id, $leadout, @bare_tracks), $VERSION);

# Ben Harper and The Relentless 7 - White Lies For Dark Times
$disc_id = q(9c0b1b0b);
$leadout = 213285;
@bare_tracks = (
    13940, 36582, 50549, 69671, 90909, 111471, 
    130442, 152699, 170300, 193124
);
fetch_url(create_freedb_query($disc_id, $leadout, @bare_tracks), $VERSION);

exit 0;

sub fetch_url {
    my $query = shift;
    my $cgi_version = shift;

    my $cddb_url = q(http://freedb.freedb.org/~cddb/cddb.cgi);
    $query .= qq(&hello=user+example.com+Streambake+$cgi_version&proto=4);
    my $ua = LWP::UserAgent->new();
    $ua->agent( q(Streambake ) . $cgi_version . q(;) . $ua->agent() );
    print qq(URL is:\n$cddb_url?$query\n);
    my $req = HTTP::Request->new( GET => qq($cddb_url?$query) );
    my $resp = $ua->request($req);
    if ( $resp->code() == HTTP_OK ) {
        print q(HTTP 200 -> CDDBP ) . $resp->decoded_content();
    } elsif ( $resp->code() == HTTP_INTERNAL_SERVER_ERROR ) {
        print q(HTTP 500 -> CDDBP ) . $resp->status_line. qq(\n);
    } else {
        print q(ERROR: an unknown error occured; ) . $resp->code();
    } # if ( $resp->code() = HTTP_OK )

} # sub fetch_url

sub create_freedb_query {
    my $disc_id = shift;
    my $leadout = shift;
    my @bare_tracks = @_;

    my @offset_tracks;
    my $disc_offset = 150;
    my $freedb_tracks;
    foreach my $track ( @bare_tracks ) {
        push(@offset_tracks, $track + $disc_offset);
    } # foreach my $track ( @bare_tracks )

    my $query_url = qq(cmd=cddb+query+$disc_id+);
    my $disc_seconds = int( ($leadout + $disc_offset) / 75);

    $query_url .= (scalar(@offset_tracks) + 1) . qq(+$disc_offset+) 
        . join(q(+), @offset_tracks) . qq(+$disc_seconds);
    return $query_url;
}

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
