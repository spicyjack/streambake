use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake::Test',
    AUTHOR              => 'Brian Manning <elspicyjack at gmail dot com>',
    VERSION_FROM        => 'lib/Streambake/Test.pm',
    ABSTRACT_FROM       => 'lib/Streambake/Test.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-Test-*' },
);
