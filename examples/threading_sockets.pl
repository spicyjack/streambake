#!/usr/bin/env perl

# $Id: perlscript.pl,v 1.7 2008/01/24 07:06:47 brian Exp $
# Copyright (c)2001 by Brian Manning

# perl script that demonstrates threading with sockets in perl
# inspired by: http://perldoc.perl.org/perlthrtut.html#Creating-Threads

# more links that may help get this working:
# http://perlmonks.org/?node_id=21054 - reading from more than one socket at
# once
# http://perlmonks.org/?node_id=371763 - using 'select' and IO::Select
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

=head1 VERSION

Revision 2010.1

=head1 DESCRIPTION

B<threading_sockets.pl> demonstrates writing to and reading from sockets after
forking off processes.  The threading is done using a Perl object wrapper
around the Perl implementation of C<threads>.  Inspired by
L<http://perldoc.perl.org/perlthrtut.html#Creating-Threads> and
L<http://hell.jedicoder.net/?p=82>.

=cut

package main;
our $VERSION = q(2010.1);
use strict;
use warnings;
use threads;
use threads::shared;
use IO::Socket::INET;

my $num_threads :shared;
my @threads = qw( logger:1 cataloger:3 worker3:5 worker4:7 );
#my @threads = qw( logger:1 cataloger:3 );
my @thread_stack;
my $sleep_time = 5;

    # create the socket that accepts new requests (the server)
    my $server = IO::Socket::INET->new(
        Listen      => 5,
        Timeout     => 500,
        Proto       => q(tcp),
        LocalPort   => 6666,
        ReuseAddr   => 1,
    );

    # loop and create clients
    foreach my $client_thread ( @threads ) {
        my ($thread_name, $thread_sleep) = split(/:/, $client_thread);
        my $thread_obj = Thread::Client->new(
            thread_name     => $thread_name,
            thread_sleep    => $thread_sleep,
            base_sleep      => $sleep_time,
        );
        push(@thread_stack, $thread_obj);
    } # foreach my $client_thread ( @threads )

    foreach my $curr_thread ( @thread_stack ) {
        print qq($$:  detaching thread ) . $curr_thread->get_tid() . qq(\n);
        #$curr_thread->join();
        $curr_thread->detach();
    } # foreach my $curr_thread ( @thread_stack )

    while (1) {
        my $client;
        warn qq(INFO: parent PID $$: calling server->accept\n);
        while ( $client = $server->accept() ) {
            warn qq(INFO: accepted connection: )
                . $client->peerhost()
                . q(, )
                . $client->peerport()
                . qq(\n);
            $client->autoflush(1);
            # create a server thread
            my $thr = Thread::Server->new(client => $client);
            my $check_num_of_threads;
            {
                lock($num_threads);
                $num_threads++;
                $check_num_of_threads = $num_threads;
            }
            warn qq(INFO: current threadcount: $check_num_of_threads\n);
            $thr->detach();
        } # while ( $client = $server->accept() )
    } # while (1)

    exit 0;

######################
### Thread::Common ###
######################
package Thread::Common;
use strict;
use warnings;
use threads;

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


######################
### Thread::Server ###
######################
package Thread::Server;
use strict;
use warnings;
use threads;
use IO::Socket::INET;
use base qw(Thread::Common);

sub new {
    my $class = shift;
    my %args = @_;

    #use Data::Dumper;
    #print Dumper %args;

    if ( ! exists $args{client} ) {
        die qq(ERROR: Thread::Server called without 'client' argument);
    }

    my $self = bless ({
        _thread_obj     => undef,
        _client     => $args{client},
    }, $class);

    $self->{_thread_obj} = threads->create( sub { $self->_process() });
    return $self;
} # sub new

sub _process {
    my $self = shift;
    my $client = $self->{_client};
    my $peer = $client->peerhost();

    # local client info
    if ( $client->connected() ) {
        print $client qq($peer : Welcome to server\n);
        while (<$client>) {
            my $received = $_;
            chomp($received);
            print qq(RECV -> $peer : $received\n);
            print $client qq($peer said: $received\n);
            my $check_num_of_threads;
            if ( $received eq q(EXIT) ) {
                {
                    lock($num_threads);
                    $num_threads--;
                    $check_num_of_threads = $num_threads;
                } # lock
                warn qq(INFO: current threadcount: $check_num_of_threads\n);
                if ( $check_num_of_threads == 0 ) {
                    exit(0);
                } # if ( $check_num_of_threads == 0 )
            } # if ( $received eq q(EXIT) )
        } # while (<$lclient>)
    } # if ( $client->connected() )
} # sub process

######################
### Thread::Client ###
######################
package Thread::Client;
use strict;
use warnings;
use threads;
use IO::Socket::INET;
use base qw(Thread::Common);

sub new {
    my $class = shift;
    my %args = @_;

    #use Data::Dumper;
    #print Dumper %args;

    if ( ! exists $args{thread_name} ) {
        die qq(ERROR: Thread::Client called without 'thread_name' argument);
    }
    if ( ! exists $args{thread_sleep} ) {
        die qq(ERROR: Thread::Client called without 'sleep_time' argument);
    }

    my $self = bless ({
        _thread_obj     => undef,
        _thread_name     => $args{thread_name},
        _thread_sleep    => $args{thread_sleep},
        _base_sleep     => $args{base_sleep},
    }, $class);

    $self->{_thread_obj} = threads->create( sub { $self->_process() });
    return $self;
} # sub new

sub _process {
    my $self = shift;

    my $total_time = 20;
    my $run_time = 0;
    my $_host = qq(localhost);
    my $_port = qq(6666);
    #sleep 1;
    my $socket = IO::Socket::INET->new(
        PeerAddr    => $_host,
        PeerPort    => $_port,
        Proto       => q(tcp),
    ); # my $socket = IO::Socket::INET->new

    if ( defined $socket ) {
        while ( $run_time < $total_time ) {
            print $socket q(Unga! ) . $self->{_thread_name}
                . q(/) . threads->tid()
                . qq(, current time: ) . sprintf( q(%02d), $run_time )
                . q(; sleeps for ) . $self->{_thread_sleep} . qq(\n);
            $run_time += $self->{_thread_sleep};
            sleep $self->{_thread_sleep};
        } # while ( $run_time < $total_time )
        print $socket qq(EXIT\n);
        $socket->close();
        threads->exit();
    } else {
        warn qq(Can't open socket to $_host:$_port: $!);
    } # if ( ! defined $socket )
    #exit 0;
    #return;

} # sub process


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
