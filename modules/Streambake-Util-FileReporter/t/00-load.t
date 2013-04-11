#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Streambake::Util::FileReporter' ) || print "Bail out!
";
}

diag( "Testing Streambake::Util::FileReporter $Streambake::Util::FileReporter::VERSION, Perl $], $^X" );
