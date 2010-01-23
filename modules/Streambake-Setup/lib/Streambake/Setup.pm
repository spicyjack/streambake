package Streambake::Setup;

use strict;
use warnings;

# we need File::Find::Rule; no point in continuing if it's not available
BEGIN {
    eval q(use File::Find::Rule; );
    if ( $@ ) {
        die qq(ERROR: Module 'File::Find::Rule' is not available);
    }
} # BEGIN

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

    use Streambake::Setup

    my $foo = Streambake->new();
    $foo->prove_all();
    # optional, run a specific test only
    # $foo->prove(test_file.t);
    ...

=head1 FUNCTIONS

=head2 new()

Creates an instance of the L<Streambake::Setup> module and returns it to the
caller.

=cut

sub new {
    my $class = shift;
    my %args = @_;

    my $verbose;
    if ( exists $args{verbose} ) {
        $verbose = $args{verbose};
    } # if ( exists $args{verbose} )

    my $self = bless ({ _verbose => $verbose }, $class);
    return $self;
}

=head2 prove( qw( Streambake::Tests::Test1 Streambake::Tests::Test2 ) )

Run the C<prove()> methods for the modules passed in.

=cut

sub prove {
    my $self = shift;
    my @test_list = @_;

    # the test directory should be below where this physical file is located
    my $test_dir = __FILE__;
    $test_dir =~ s/Setup.pm$/Tests/;

    # create the file find rule
    my $rule = File::Find::Rule->new();
    # get a list of files to test with
    my @files = $rule->in($test_dir);
    foreach my $requested_test ( @test_list ) {
        # see if the user's requested test is in the list of files found
        my @testfiles = grep(/$requested_test/, @files );
        if ( scalar(@testfiles) > 0 ) {
            # we can only check for one test file at a time, so the below is
            # safe
            open (TEST, "< " . $testfiles[0]);
            my $test_text = <TEST>;
            # evaluate the code in the test file, return whatever it spits out
            my $return_text = eval $test_text;
        } # if ( scalar(@testfiles) > 0 )
    } # foreach my $requested_test ( @test_list )
} # sub prove

=head2 prove_all()

Run the C<prove()> methods in all of the test modules that are found.

=cut

sub prove_all {
    my $self = shift;

    # set the find rule to look for only files
    my $rule = File::Find::Rule->file()->name('*.t');
    # the test directory should be below where this physical file is located
    my $test_dir = __FILE__;
    $test_dir =~ s/Setup.pm$/Tests/;
    # go over each test file found and eval it
    foreach my $file ( $rule->in($test_dir) ) {
        #print qq(Running test $file\n);
        my $filename = (split(q(/), $file))[-1];
        open (TEST, "< " . $file);
        # join the lines back together and put them in one scalar
        my $test_text = join(q(), <TEST>);
        close(TEST);
        #print qq(test text is:\n) . join(q(), @test_text) . qq(\n);
        # evaluate the code in the test file, return whatever it spits out
        # the test text will return some output we want to show to the user
        my %test_reply = eval $test_text;
        if ( length($@) > 0 ) {
            if ( $self->is_verbose() ) {
                print qq(Test file '$filename'\n);
                print qq( !! Test returned an error; module not available!\n);
                print qq( ======= Begin Module Load Output =======\n);
                print $@; 
                print qq( ======= End Module Load Output =======\n);
            } else {
                print qq(Test file '$filename'\n);
                print qq( !! Test returned an error; module not available!\n);
                print qq| (Hint: use --verbose to print test errors)\n|;
            } # if ( $self->is_verbose() )
        }
        if ( scalar(keys(%test_reply)) > 0 ) {
           print qq(Test file '$filename'\n);
           print qq( description - ) . $test_reply{description} . qq(\n);
           print qq( required? - ) . $test_reply{required} . qq(\n);
           print qq( test text output: ) . $test_reply{output_text} . qq(\n);
        } # if ( length($@) > 0 )
    } # foreach my $file ( $rule->in($test_dir) )
} # sub prove_all

=head2 is_verbose()

Returns the verbose flag set which may or may not have been set when the
object was created.

=cut

sub is_verbose {
    my $self = shift;

    if ( defined $self->{_verbose} ) {
        return 1;
    } else {
        return 0;
    } # f ( defined $self->{_verbose} )
} # sub is_verbose

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