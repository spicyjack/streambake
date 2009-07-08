#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake::Helper' );
}

diag( "Testing Streambake::Helper $Streambake::Helper::VERSION, Perl $], $^X" );
