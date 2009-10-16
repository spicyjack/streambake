package Streambake::Setup;

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

=head1 NAME

Streambake::Setup - Run a battery of tests to determine if the
software/hardware requirements are in place to run an instance of Streambake.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Streambake;

    my $foo = Streambake->new();
    ...

=head1 FUNCTIONS

=head2 prove( qw( Streambake::Tests::Test1 Streambake::Tests::Test2 ) )

Run the C<prove()> methods for the modules passed in.

=cut

sub prove {
    my $self = shift;
    my @modules = @_;
}

=head2 prove_all()

Run the C<prove()> methods in all of the test modules that are found.

=cut

sub prove_all {
    my $self = shift;
}

=head1 AUTHOR

Brian Manning, C<< <elspicyjack at gmail dot com> >>

Please do not e-mail the module author directly with Streambake issues; you
will be politely asked to send an e-mail to the mailing list (below) instead.

=head1 BUGS

Please report any bugs via the Streambake Issue Tracker page (below).

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Streambake


You can also look for information at:

=over 4

=item * Streambake Google Groups Page

L<http://groups.google.com/group/streambake>

=item * Streambake Google Groups Mailing List

L<mailto:streambake@googlegroups.com>

=item * Streambake Issue Tracker

L<http://code.google.com/p/streambake/issues/list>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to the original authors/hackers of the C<streamcast> script, as well as
anyone who has ever created a Perl module and posted it on CPAN for others to
use.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Streambake
