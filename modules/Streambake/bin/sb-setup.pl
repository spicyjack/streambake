#!/usr/bin/env perl

use warnings;
use strict;

=head1 NAME

sb-setup.pl - A setup script for Streambake.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<sb-setup.pl> script can perform the following actions:

=over 4

=item --check) Check module dependencies  

Checks for module dependencies and verifies versions.

=item Create a configuration file (--config)

Parses all of the Streambake modules in order to create a configuration file
that can be used with Streambake.

=item Upgrade check (--upgrade-check)

Checks the current installation of Streambake (if any) and prints out what
actions will be performed during an upgrade of Streambake.

=item Debugging info (--debug-info)

Prints verbose debug info, including versions of Perl and major core modules,
as well as the same modules as the C<--check> option above.  This would be
used when reporting bugs/problems with L<Streambake>.

=back

=cut

# load modules here?

=pod

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
