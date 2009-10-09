#!/usr/bin/env perl

# $Id: perlscript.pl,v 1.7 2008/01/24 07:06:47 brian Exp $
# Copyright (c)2001 by Brian Manning

# perl script that demonstrates threading with sockets in perl
# inspired by: http://perldoc.perl.org/perlthrtut.html#Creating-Threads

# more links that may help get this working:
# http://perlmonks.org/?node_id=21054 - reading from more than one socket at
# once
# http://perlmonks.org/?node_id=371720 - using 'select' and IO::Select
# http://perlmonks.org/?node_id=662931 - simple threaded chat server
# http://perlmonks.org/?node_id=539419 - threaded tcp server problem
# http://perlmonks.org/?node_id=766171 - multithreaded server with shared
# sockets
# http://perldoc.perl.org/IO/Select.html
# http://perldoc.perl.org/perlthrtut.html

=head1 NAME

threading_sockets.pl - a demo of threading and reading/writing to sockets

=head1 DESCRIPTION

B<threading_sockets.pl> demonstrates writing to and reading from sockets after
forking off processes.  The threading is done using a Perl object wrapper
around the Perl implementation of C<threads>.  Inspired by
L<http://perldoc.perl.org/perlthrtut.html#Creating-Threads> and
L<http://hell.jedicoder.net/?p=82>.

=cut

package main;
$main::VERSION = (q$Revision: 1.7 $ =~ /(\d+)/g)[0];
use strict;
use warnings;

my @threads = qw( boss:1 worker1:3 worker2:5 worker3:7 );
my @thread_stack;

    foreach my $this_thread ( @threads ) {
        my ($thread_name, $thread_sleep) = split(/:/, $this_thread);
        my $thread_obj = Thread::Creator->new(
            name =>     $thread_name, 
            sleep =>    $sleep_time
        );
        push(@thread_stack, $thread_obj);
    } # foreach my $this_thread ( @threads )

    foreach my $curr_thread ( @thread_stack ) {
        #print qq($$: joining thread ) . $curr_thread->tid() . qq(\n);
        $curr_thread->join();
        #$curr_thread->detach();
    } # foreach my $curr_thread ( @thread_stack )
    exit 0;

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
            my $thread = threads->self();
            print qq(Unga! $thread_name/$$-) . $thread->tid()
                . qq(, slept for $sleep_time, $run_time\n);
            $run_time += $sleep_time;
        }
    }

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

sub new {
    my $class = shift;
    my $thread_name = shift;
    my $self = bless ({
        _thread => undef,
    }, $class);

    $self->{_thread} = threads->create( 
        sub { Thread::Creator->do_work($thread_name) }
    );
    return $self;
} # sub new

sub do_work {
    my $self = shift;
    my $thread_name = shift;

    my $times_worked = 0;
    while ( $times_worked < 5 ) {
        print qq(Unga! $thread_name/) . threads->tid() 
            . qq(, slept for $sleep_time, $run_time\n);
        $times_worked++;
        sleep 5;
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

# vi: set ft=perl sw=4 ts=4:
# EOF
