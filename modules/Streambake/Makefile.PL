use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake::Simple',
    AUTHOR              => 'Brian Manning <elspicyjack@gmail.com>',
    VERSION_FROM        => 'lib/Streambake/Simple.pm',
    ABSTRACT_FROM       => 'lib/Streambake/Simple.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-*' },
);
