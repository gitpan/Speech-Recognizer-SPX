use ExtUtils::MakeMaker;
use Getopt::Long;
use strict;
use vars qw($SPX_PREFIX $SPX_DIR);

GetOptions('sphinx-prefix=s' => \$SPX_PREFIX);

my @possible_prefixes;
if (defined $SPX_PREFIX) {
    @possible_prefixes = ($SPX_PREFIX);
} else {
    @possible_prefixes = qw(
			    /usr
			    /usr/local
			    /usr0
			    /usr0/sphinx
			    /opt/sphinx
			    /opt/sphinx2
			   );
}

undef $SPX_PREFIX;
foreach my $dir (@possible_prefixes) {
    if (-d "$dir/lib"
	and -d "$dir/share/sphinx2/model/hmm"
	and -d "$dir/share/sphinx2/model/lm") {
	$SPX_PREFIX = $dir;
	$SPX_DIR = "$dir/share/sphinx2";
	last;
    }
}

unless (defined($SPX_DIR)) {
    local $" = "\n";
    print <<"EOF";
No Sphinx2 installation could be found in any of the following
directories:

@possible_prefixes

Please specify the --prefix option used to configure Sphinx2 on the
command-line for 'perl Makefile.PL" like this:

\$ perl Makefile.PL --sphinx-prefix=/path/where/you/installed/it

If you are unsure where this is, ask your system administrator,
or whoever installed Sphinx2 on your system.
EOF
    exit 1;
}

print "Found Sphinx-II in $SPX_PREFIX and $SPX_DIR\n";
unlink './SPX/Config.pm';
open CONFIG, ">./SPX/Config.pm"
    or die "can't open ./SPX/Config.pm: $!";
print CONFIG <<EOF;
package Speech::Recognizer::SPX;
\$PREFIX = '$SPX_PREFIX';
\$SPHINXDIR = '$SPX_DIR';
1;
EOF
close CONFIG;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      NAME	   => 'Speech::Recognizer::SPX',
	      VERSION_FROM => 'SPX.pm',
	      LIBS	   => ["-L$SPX_PREFIX/lib -lsphinx2 -lsphinx2ad -lsphinx2fe -lm"],
	      INC          => "-I$SPX_PREFIX/include",
	      OPTIMIZE     => '-g -O2',
	      # For Speech::Recognizer::SPX::Server
	      PREREQ_PM    => { 'Time::HiRes' => 0 },
	      clean        => { FILES => 'SPX/Config.pm' },
);
