#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Streambake::Media' );
}

diag( "Testing Streambake::Media $Streambake::Media::VERSION, Perl $], $^X" );
