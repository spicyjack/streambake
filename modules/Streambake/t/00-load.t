#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake' );
}

diag( "Testing Streambake $Streambake::VERSION, Perl $], $^X" );
