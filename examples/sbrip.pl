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

my ($discid, $colorlog, $indir, $outdir);
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
    Login => $login_id,           # defaults to %ENV's
) or die $!;

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
