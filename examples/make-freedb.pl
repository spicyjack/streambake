#!/usr/bin/perl        
# Usage:
#
#      my $id = compute_discid ($leader, @frames);
#
# "$leader" is the number of frames before track 1.
# "@frames" is the length in frames of each track on the disc.
# (A frame is 1/75th of a second.)
# Returns the disc ID as a string.

use POSIX;

sub cddb_sum {
  # a number like 2344 becomes 2+3+4+4 (13).
  my ($n) = @_;
  my $ret = 0;
  while ($n > 0) {
    $ret += ($n % 10);
    $n /= 10;
  }
  return $ret;
}

sub compute_discid {
  my @frames = @_;

  my $tracks = $#frames + 1;
  my $n = 0;

  my @start_secs;
  my $i;

  for ($i = 0; $i < $tracks; $i++) {
    $start_secs[$i] = POSIX::floor ($frames[$i] / 75);
  }

  for ($i = 0; $i < $tracks-1; $i++) {
    $n = $n + cddb_sum ($start_secs[$i]);
  }

  my $t = $start_secs[$tracks-1] - $start_secs[0];

  my $id = ((($n % 0xFF) << 24) | ($t << 8) | $tracks-1);
  return sprintf ("%08x", $id);
}

