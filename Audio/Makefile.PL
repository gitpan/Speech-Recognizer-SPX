use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Audio::SPX',
    'VERSION_FROM' => 'SPX.pm', # finds $VERSION
    'LIBS'	=> ['-lsphinx2ad -lm'],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'OPTIMIZE'    => '-g -O2',
);
