use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake::Setup',
    AUTHOR              => 'Brian Manning <bmanning@qualcomm.com>',
    VERSION_FROM        => 'lib/Streambake/Setup.pm',
    ABSTRACT_FROM       => 'lib/Streambake/Setup.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-Setup-*' },
);
