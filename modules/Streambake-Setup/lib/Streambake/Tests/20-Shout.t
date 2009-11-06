#!/usr/bin/env perl

# variable for storing the version number
my $version;
use Shout; 
# Shout has it's VERSION string in a BEGIN{} block; must instantiate an object
# to be able to read it
Shout->new(); 
# FIXME return the test text to the caller, so the caller can eval it instead
# of this script running it's own eval() block; that way, the caller of this
# script can print out whether or not this appication is recommended/required,
# which we would not be able to do if this script fails to run due to a
# missing module or ???
#
# so return
# required, description, test output text, and the text that makes up the test
return (
    required => q(yes), 
    description => q(Shout, a Perl interface to 'libshout'),
    output_text => qq(Shout available, version ) . $Shout::VERSION,
    test_text => 
        q|my $version; use Shout; Shout->new(); return $Shout::VERSION;|,
);
