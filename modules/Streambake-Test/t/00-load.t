#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake::Test' );
}

diag( "Testing Streambake::Test $Streambake::Test::VERSION, Perl $], $^X" );
