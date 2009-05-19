#!/usr/bin/env perl

# $Id$
# $Author$
# *DO NOT* contact the author of the software for support.
# For support, please visit the Streambake homepage/mailing list at:
# http://groups.google.com/group/streambake or <streambake@googlegroups.com>

# License terms at the bottom of this file

use strict;
use warnings;
use CDDB;
use Getopt::Long;
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

my $cddbp = new CDDB(
    Host  => 'freedb.freedb.org', # default
    Port  => 8880,                # default
    #Login => $login_id,           # defaults to %ENV's
    Login => q(win32usr),          # defaults to %ENV's
) or die $!;

my @genres = $cddbp->get_genres();
print qq(Genres: ) . join(q(, ), @genres) . qq(\n);

my @toc = (
    # QOTSA - QOTSA
    q(  1    0  0  0),
    q(  2    4 35 17),
    q(  3    7 57 62),
    q(  4   11 18 30), 
    q(  5   16 21 55), 
    q(  6   20 37 70), 
    q(  7   24 08 62), 
    q(  8   29 03 17), 
    q(  9   31 48 10), 
    q( 10   38 22 05), 
    q( 10   41 31 62), 
    q(999   46 33 17)
); # my @toc

my (
    $cddbp_id,      # used for further cddbp queries
    $track_numbers, # padded with 0's (for convenience)
    $track_lengths, # length of each track, in MM:SS format
    $track_offsets, # absolute offsets (used for further cddbp queries)
    $total_seconds  # total play time, in seconds (for cddbp queries)
) = $cddbp->calculate_id(@toc);

print qq(Found disc id $cddbp_id for TOC\n);

exit 0;

my $disc = $cddbp->get_disc_details($discid, q(newage));
print qq(Disc title is ) . $disc->{title} . qq(\n);

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
