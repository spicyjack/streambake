use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Streambake',
    AUTHOR              => 'Brian Manning <elspicyjack at gmail dot com>',
    VERSION_FROM        => 'lib/Streambake.pm',
    ABSTRACT_FROM       => 'lib/Streambake.pm',
    # files copied bin directory; If these are perl scripts, these files are
    # created or deleted depending on which make target you invoke
    EXE_FILES           => [ 'bin/streambake.pl', 'bin/setup.pl' ],
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'HTTP::Status'      => 5.817,
        'Streambake::Media' => 0.1,
        'Test::More'        => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Streambake-*' },
);
