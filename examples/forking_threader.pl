#!/usr/bin/env perl

# $Id: perlscript.pl,v 1.7 2008/01/24 07:06:47 brian Exp $
# Copyright (c)2001 by Brian Manning
#
# perl script that demonstrates forking and threading in perl
# inspired by: http://perldoc.perl.org/perlthrtut.html#Creating-Threads

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

=pod

=head1 NAME

SomeScript

=head1 DESCRIPTION

B<SomeScript> does I<Something>

=cut

package main;
$main::VERSION = (q$Revision: 1.7 $ =~ /(\d+)/g)[0];
use strict;
use warnings;


=head1 VERSION

The CVS version of this file is $Revision: 1.7 $. See the top of this file for
the author's version number.

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

# vi: set ft=perl sw=4 ts=4 cin:
# end of line
1;

my @children;

foreach my $fork_name ( qw( odin:3 dva:5 tri:7 chetyre:9 pyat:11 ) ) {
    my $pid = fork();
    if ($pid) {
        # parent
        push(@children, $pid . q(:) . $fork_name);
    } elsif ($pid == 0) {
        # child
        my ($fork_name, $sleep_time) = split(/:/, $fork_name);
        my $total_time = 100;
        my $run_time = 0;

        while ( $run_time < $total_time ) {
            sleep $sleep_time;
            print qq(Unga! $fork_name/$$, slept for $sleep_time, $run_time\n);
            $run_time += $sleep_time;
        } # while ( $run_time < $total_time )
        exit 0;
    } # if ($pid)
} # foreach my $fork_name

foreach ( @children ) {
    my $pid = (split(/:/, $_))[0];
    waitpid($pid, 0);
} # foreach ( @children )
package Thread::Creator;
use strict;
use warnings;
use threads;

sub new {
    my 
    my $thr1 = threads->create(\&sub1, q(odin), 3);
    my $thr2 = threads->create(\&sub1, q(dva), 5);
    my $thr3 = threads->create(\&sub1, q(tri), 7);
    my $thr4 = threads->create(\&sub1, q(chetyre), 9);
    my $thr5 = threads->create(\&sub1, q(pyat), 11);

    $thr1->join();
    $thr2->join();
    $thr3->join();
    $thr4->join();
    $thr5->join();

    sub sub1 {
        my $thread_name = shift;
        my $sleep_time = shift;
        my $total_time = 100;
        my $run_time = 0;

        while ( $run_time < $total_time ) {
            sleep $sleep_time;
            print qq(Unga! $thread_name/$$, slept for $sleep_time, $run_time\n);
            $run_time += $sleep_time;
        }
    }

=head1 FUNCTIONS 

=head2 SomeFunction()

SomeFunction() is a function that does something.  

=head1 VERSION

The CVS version of this file is $Revision: 1.7 $. See the top of this file for
the author's version number.

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

# vi: set ft=perl sw=4 ts=4 cin:
# end of line
1;

