#!/usr/bin/env perl

# $Id: perlscript.pl,v 1.7 2008/01/24 07:06:47 brian Exp $
# Copyright (c)2001 by Brian Manning

=pod

=head1 NAME

oo_forking_threader.pl - a demo of threaded forks

=head1 DESCRIPTION

B<oo_forking_threader.pl> demonstrates threading after forking.  The threading
is done using a Perl object wrapper around the Perl implementation of
C<threads>.  Inspired by
L<http://perldoc.perl.org/perlthrtut.html#Creating-Threads> and
L<http://hell.jedicoder.net/?p=82>.

=cut

package main;
$main::VERSION = (q$Revision: 1.7 $ =~ /(\d+)/g)[0];
use strict;
use warnings;

my @children;

#foreach my $fork_name ( qw( odin:3 dva:5 tri:7 chetyre:9 pyat:11 ) ) {
foreach my $fork_name ( qw( odin dva tri chetyre ) ) {
    my $pid = fork();
    if ($pid) {
        # parent
        push(@children, $pid . q(:) . $fork_name);
    } elsif ($pid == 0) {
        # child
        my $thread_obj = Thread::Creator->new($fork_name);
        my @threads = $thread_obj->get_thread_list();
        foreach my $curr_thread ( @threads ) {
            #print qq($$: joining thread ) . $curr_thread->tid() . qq(\n);
            $curr_thread->join();
            #$curr_thread->detach();
        }
        exit 0;
#        next;
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

my @_thread_list;

sub new {
    my $class = shift;
    my $fork_name = shift;
    my $self = bless ({}, $class);

    foreach my $thread_tmpl ( qw( uno:3 dos:5 tres:7 cuatro:11 ) ) {
        my ($thr_name, $sleep_time) = split(/:/, $thread_tmpl);
        print qq(fork: $fork_name; creating thread '$thr_name', with a )
            . qq(sleep time of $sleep_time\n);
        my $thr = threads->create( 
            #sub { $self->do_work($fork_name, $thr_name, $sleep_time) }
            sub { Thread::Creator->do_work($fork_name, $thr_name, $sleep_time) }
        );
        #$thr->detach();
        #$thr->join();
        push(@_thread_list, $thr);
    } # foreach my $thread_tmpl ( qw( uno:3 dos:5 tres:7 cuatro:11 ) )

    return $self;
} # sub new

sub get_thread_list {
    return @_thread_list;
} # sub get_thread_list

sub do_work {
    my $self = shift;
    my $fork_name = shift;
    my $thread_name = shift;
    my $sleep_time = shift;
    #my $total_time = 30;
    my $total_time = 100;
    my $run_time = 0;

    while ( $run_time < $total_time ) {
        sleep $sleep_time;
        print qq(Unga! $fork_name/$$ -> $thread_name/) . threads->tid() 
            . qq(, slept for $sleep_time, $run_time\n);
        $run_time += $sleep_time;
    } # while ( $run_time < $total_time )
    #exit 0;
} # sub do_work

=head1 VERSION

The CVS version of this file is $Revision: 1.7 $. See the top of this file for
the author's version number.

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

### begin license blurb
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

# vi: set ft=perl sw=4 ts=4 cin:
# end of line
