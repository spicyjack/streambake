#!/usr/bin/env perl

# variable for storing the version number
my $version;
use Shout; 
# Shout has it's VERSION string in a BEGIN{} block; must instantiate an object
# to be able to read it
Shout->new(); 
return (
    required => q(yes), 
    description => q(Shout, a Perl interface to 'libshout'),
    output_text => qq(Shout available, version ) . $Shout::VERSION,
);
