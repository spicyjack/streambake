use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake',
    AUTHOR              => 'Brian Manning <elspicyjack at gmail dot com>',
    VERSION_FROM        => 'lib/Streambake.pm',
    ABSTRACT_FROM       => 'lib/Streambake.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-*' },
);
