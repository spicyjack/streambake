use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Simplebake',
    AUTHOR              => 'Brian Manning <elspicyjack@gmail.com>',
    VERSION_FROM        => 'bin/simplebake.pl',
    ABSTRACT            => 'Stream MP3/OGG from a list of files to an Icecast server',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Simplebake-*' },
);
