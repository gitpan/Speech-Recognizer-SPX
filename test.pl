# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Speech::Recognizer::SPX qw(:uttproc :fbs $SPHINXDIR);
use Speech::Recognizer::SPX::Server;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

fbs_init({-live		=> 'TRUE',
	  -samp		=> 16000,
	  -adcin	=> 'TRUE',
	  -ctloffset	=> 0,
	  -ctlcount	=> 100000000,
	  -cepdir	=> "$SPHINXDIR/model/lm/turtle",
	  -datadir	=> "$SPHINXDIR/model/lm/turtle",
	  -agcmax	=> 'FALSE',
	  -langwt	=> 6.5,
	  -fwdflatlw	=> 8.5,
	  -rescorelw	=> 9.5,
	  -ugwt		=> 0.5,
	  -fillpen	=> 1e-10,
	  -silpen	=> 0.005,
	  -inspen	=> 0.65,
	  -top		=> 1,
	  -topsenfrm	=> 3,
	  -topsenthresh	=> -70000,
	  -beam		=> 2e-06,
	  -npbeam	=> 2e-06,
	  -lpbeam	=> 2e-05,
	  -lponlybeam	=> 0.0005,
	  -nwbeam	=> 0.0005,
	  -fwdflat	=> 'FALSE',
	  -fwdflatbeam	=> 1e-08,
	  -fwdflatnwbeam=> 0.0003,
	  -bestpath	=> 'TRUE',
	  -kbdumpdir	=> $SPHINXDIR,
	  -lmfn		=> "$SPHINXDIR/model/lm/turtle/turtle.lm",
	  -dictfn	=> "$SPHINXDIR/model/lm/turtle/turtle.dic",
	  -phnfn	=> "$SPHINXDIR/model/hmm/6k/phone",
	  -mapfn	=> "$SPHINXDIR/model/hmm/6k/map",
	  -hmmdir	=> "$SPHINXDIR/model/hmm/6k",
	  -hmmdirlist	=> "$SPHINXDIR/model/hmm/6k",
	  -ndictfn	=> "$SPHINXDIR/model/hmm/6k/noisedict",
	  '-8bsen'	=> 'TRUE',
	  -sendumpfn	=> "$SPHINXDIR/model/hmm/6k/sendump",
	  -cbdir	=> "$SPHINXDIR/model/hmm/6k"});


open WAV, "<testwav.raw" or die "couldn't open testwav.raw: $!";
uttproc_begin_utt();
my $count = 0;
while (defined(my $b = read WAV, my($buf), 4096)) {
    last if $b == 0;
    $count += $b;
    uttproc_rawdata($buf, 1)
	or die "uttproc_rawdata failed";
    if ($count > 50000 and $count < 54096) {
	my ($fr, $hyp) = uttproc_partial_result();
	if ($hyp =~ /TO THE LAB/i) {
	    print "ok 2\n";
	} else {
	    print "not ok 2\n";
	}
    }
}
uttproc_end_utt();
my ($fr, $hyp) = uttproc_result(1);
print "frames $fr\n";
fbs_end();

if ($hyp =~ /GO TO THE LAB SAY HELLO TO ROBOMAN QUIT/i) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}
