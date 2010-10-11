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
# http://perldoc.perl.org/threads.html
# http://perldoc.perl.org/perlipc.html
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
use IO::Socket::INET;

my @threads = qw( worker1:1 worker2:3 worker3:5 worker4:7 );
my @thread_stack;
my $sleep_time = 5;


    # loop and create client sockets
    foreach my $this_thread ( @threads ) {
        my ($thread_name, $thread_sleep) = split(/:/, $this_thread);
        my $thread_obj = Thread::Creator->new(
            thread_name		=> $thread_name, 
            thread_sleep	=> $thread_sleep,
			base_sleep		=> $sleep_time,
        );
        push(@thread_stack, $thread_obj);
    } # foreach my $this_thread ( @threads )

    # create the socket that accepts new requests (the server)
    my $server = IO::Socket::INET->new(
        Listen      => 5,
        Timeout     => 500,
        Proto       => q(tcp),
        LocalPort   => 6666,
        ReuseAddr   => 1,
    );
    foreach my $curr_thread ( @thread_stack ) {
        print qq($$:  detaching thread ) . $curr_thread->get_tid() . qq(\n);
        #$curr_thread->join();
        $curr_thread->detach();
    } # foreach my $curr_thread ( @thread_stack )

    while (1) {
        my $client;
        warn qq(calling server->accept);
        do {
            $client = $server->accept();
        } until ( defined($client) );
        my $peerhost = $client->peerhost();
        my $peerport = $client->peerport();
        print qq(Accepted client $client, $peerhost, $peerport\n);
        my $thr = threads->new( \&process, $client, $peerhost);
        $thr->detach();
    } # while (1)

    exit 0;

sub process {
    # local client info
    my ($lclient, $lpeer) = @_;
    if ( $lclient->connected() ) {
        print $lclient qq($lpeer: Welcome to server\n);
        while (<$lclient>) { print $lclient qq($lpeer said: $_\n); }
    } # if ( $client->connected() )
    close ($lclient);
} # sub process

package Thread::Creator;
use strict;
use warnings;
use threads;
use IO::Socket::INET;

sub new {
    my $class = shift;
    my %args = @_;

	#use Data::Dumper;
	#print Dumper %args;

	if ( ! exists $args{thread_name} ) { 
		die qq(ERROR: Thread::Creator called without 'thread_name' argument);
	}
	if ( ! exists $args{thread_sleep} ) { 
		die qq(ERROR: Thread::Creator called without 'sleep_time' argument);
	}

    my $self = bless ({
        _thread_obj 	=> undef,
		_thread_name 	=> $args{thread_name},
		_thread_sleep	=> $args{thread_sleep},
		_base_sleep 	=> $args{base_sleep},
    }, $class);

    $self->{_thread_obj} = threads->create( sub { $self->_do_work() });
    return $self;
} # sub new

sub join {
	my $self = shift;

	my $thread_obj = $self->{_thread_obj};
	$thread_obj->join();

} # sub join

sub detach {
	my $self = shift;

	my $thread_obj = $self->{_thread_obj};
	$thread_obj->detach();

} # sub join

sub get_tid {
	my $self = shift;

	my $thread_obj = $self->{_thread_obj};
	return $thread_obj->tid();

} # sub join

sub _do_work {
	my $self = shift;

	my $total_time = 50;
	my $run_time = 0;
    my $_host = qq(localhost);
    my $_port = qq(6666);
    sleep 5;
    my $socket = IO::Socket::INET->new(
        PeerAddr    => $_host,
        PeerPort    => $_port,
        Proto       => q(tcp),
    ); # my $socket = IO::Socket::INET->new
    
    if ( defined $socket ) {
        print qq(ERROR: can't connect to port $_port on host $_host: $!\n);
        while ( $run_time < $total_time ) {
            print $socket q(Unga! ) . $self->{_thread_name} 
                . q(/) . threads->tid() 
                . qq(, current time: ) . sprintf( q(%02d), $run_time )
                . q(; sleeps for ) . $self->{_thread_sleep} . qq(\n);
            $run_time += $self->{_thread_sleep};
            sleep $self->{_thread_sleep};
        } # while ( $run_time < $total_time )
    } else {
        warn qq(Can't open socket to $_host:$_port: $!);
    } # if ( ! defined $socket )
    #exit 0;
} # sub _do_work


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
