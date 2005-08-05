use ExtUtils::MakeMaker;
use strict;
use vars qw($SPX_PREFIX);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# The audio interface has some nasty incompatibility problems between
# <0.5, 0.5, and >0.5.  We will try to account for them here.
my $defs;
if (open CONTAD, "<$SPX_PREFIX/include/sphinx2/cont_ad.h") {
    while (<CONTAD>) {
	if (/cont_ad_set_params/) {
	    while (1) {
		last if /^$/;
		if (/adapt_rate/) {
		    $defs .= "-DHAVE_ADAPT_RATE ";
		    last;
		}
		last unless defined($_=<CONTAD>);
	    }
	}
	if (/cont_ad_set_logfp/) {
	    while (1) {
		last if /^$/;
		if (/cont_ad_t/) {
		    $defs .= "-DHAVE_C_LOGFP ";
		    last;
		}
		last unless defined($_=<CONTAD>);
	    }
	}
    }
}
else {
    warn "Failed to open $SPX_PREFIX/include/cont_ad.h, assuming most recent version.\n";
    $defs = "-DHAVE_ADAPT_RATE -DHAVE_C_LOGFP";
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Audio::SPX',
    'VERSION_FROM' => 'SPX.pm', # finds $VERSION
    'LIBS'	=> ["-L$SPX_PREFIX/lib -lsphinx2 -lsphinx2fe -lsphinx2ad -lm"],   # e.g., '-lm' 
    'DEFINE'	=> $defs,
    'INC'          => "-I$SPX_PREFIX/include",
    'OPTIMIZE'    => '-g -O2',
);
