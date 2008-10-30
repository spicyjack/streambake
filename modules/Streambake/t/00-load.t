#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake::Simple' );
}

diag( "Testing Streambake::Simple $Streambake::Simple::VERSION, Perl $], $^X" );
