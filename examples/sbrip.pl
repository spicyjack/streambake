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

$get_url = qq($cddb_url?cmd=cddb+query+11+20642+35837+50880+73630)
    . q(92845+108662+130742+143110+172655+186887+209492);
fetch_url($get_url, $version);

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
    if ( $resp->is_success() ) {
        print $resp->decoded_content();
    } else {
        print q(ERROR: ) . $resp->status_line. qq(\n);
    }
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
