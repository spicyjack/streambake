#!perl -T

# ideas for testing simplebake...
# http://www252.pair.com/comdog/mastering_perl/Chapters/18.modulinos.html
# http://www.perlmonks.org/index.pl?node_id=396759

use Test::More q(no_plan);

my $simplebake_file = q(../bin/simplebake.pl);
my $result = do $simplebake_file;
print $result . qq(\n);
ok($result, qq(result got: $result));
#my $sbc = Simplebake::Config->new();
#ok( defined $sbc );
diag( "Testing Simplebake $main::VERSION, Perl $], $^X" );
