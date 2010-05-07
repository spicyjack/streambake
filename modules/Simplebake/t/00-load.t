#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Simplebake' );
}

diag( "Testing Simplebake $Simplebake::VERSION, Perl $], $^X" );
