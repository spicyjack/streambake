use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake::Util::FileReporter',
    AUTHOR              => q{Brian Manning <brian at xaoc dot org>},
    VERSION_FROM        => 'lib/Streambake/Util/FileReporter.pm',
    ABSTRACT_FROM       => 'lib/Streambake/Util/FileReporter.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-Util-FileReporter-*' },
);
