use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Simplebake',
    AUTHOR              => 'Brian Manning <elspicyjack@gmail.com>',
    VERSION_FROM        => 'bin/simplebake.pl',
    ABSTRACT_FROM       => 'bin/simplebake.pl',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Simplebake-*' },
);
