use ExtUtils::MakeMaker;
use strict;
use vars qw($SPX_PREFIX);

my @defs;
if (open FE_H, "<$SPX_PREFIX/include/sphinx2/fe.h") {
    while (<FE_H>) {
	if (/\*nframes/) {
	    print "Detected post-0.6 frontend API\n";
	    push @defs, '-DPOST_0_6_FE';
	    last;
	}
    }
}
else {
    warn "Failed to open $SPX_PREFIX/include/sphinx2/fe.h, compilation may fail\n";
}


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Audio::MFCC',
    'VERSION_FROM' => 'MFCC.pm', # finds $VERSION
    'LIBS'	=> ["-L$SPX_PREFIX/lib -lsphinx2 -lsphinx2fe -lm"],   # e.g., '-lm' 
    'DEFINE'	=> "@defs",
    'INC'          => "-I$SPX_PREFIX/include",
    'OPTIMIZE'    => '-g -O2',
);
