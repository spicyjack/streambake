#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake::Setup' );
}

diag( "Testing Streambake::Setup $Streambake::Setup::VERSION, Perl $], $^X" );
