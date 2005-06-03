use ExtUtils::MakeMaker;
use strict;
use vars qw($SPX_PREFIX);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Audio::SPX',
    'VERSION_FROM' => 'SPX.pm', # finds $VERSION
    'LIBS'	=> ["-L$SPX_PREFIX/lib -lsphinx2 -lsphinx2fe -lsphinx2ad -lm"],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'          => "-I$SPX_PREFIX/include",
    'OPTIMIZE'    => '-g -O2',
);
