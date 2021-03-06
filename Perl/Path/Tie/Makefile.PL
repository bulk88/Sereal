use 5.008;

use strict;
use warnings;

my $shared_dir = "../../shared";
my $in_source_repo = -d "../../../.git" and -d $shared_dir;
unshift @INC, "..", "../inc";
unshift @INC, $shared_dir, "$shared_dir/inc" if $in_source_repo;

require inc::Sereal::BuildTools;
inc::Sereal::BuildTools::link_files($shared_dir, 'without_tests') if $in_source_repo;

if ($in_source_repo) {
    foreach (qw/lib Tie.xs/) {
        -l $_ && unlink($_);
        symlink("../$_", $_) or warn $!;
    }
}

my $libs = '';
my $objects = '$(BASEEXT)$(OBJ_EXT) ../Iterator/srl_iterator.o ../Iterator/srl_decoder.o';
my $defines = inc::Sereal::BuildTools::build_defines();

# Prefer external libraries over the bundled one.
inc::Sereal::BuildTools::check_external_libraries(\$libs, \$defines, \$objects);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
inc::Sereal::BuildTools::WriteMakefile(
    MIN_PERL_VERSION => '5.008',
    META_MERGE => {
        resources => {
            repository => {
              url => 'git://github.com/Sereal/Sereal.git',
            },
            bugtracker => {
              web => 'https://github.com/Sereal/Sereal/issues',
            },
        },
        'meta-spec' => { version => 2 },
    },
    BUILD_REQUIRES => {
        'File::Find' => 0,
        'File::Path' => 0,
        'ExtUtils::ParseXS' => '2.21',
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '7.0',
    },
    NAME              => 'Sereal::Path::Tie',
    VERSION_FROM      => 'lib/Sereal/Path/Tie.pm', # finds $VERSION
    PREREQ_PM         => { 'XSLoader' => 0 },
    LICENSE           => 'perl',
    ABSTRACT_FROM     => 'lib/Sereal/Path/Tie.pm',
    AUTHOR            => 'Ivan Kruglov <ivan.kruglov@yahoo.com>',
    LIBS              => [$libs], # e.g., '-lm'
    DEFINE            => $defines,
    INC               => '-I..', # e.g., '-I. -I/usr/include/other'
    OPTIMIZE          => inc::Sereal::BuildTools::build_optimize(),
    OBJECT            => $objects,
);
