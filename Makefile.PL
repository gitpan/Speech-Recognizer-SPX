use ExtUtils::MakeMaker;
use Getopt::Long;
use strict;

my($prefix, $sphinxdir);
GetOptions('sphinx-prefix=s' => \$prefix);

my @possible_prefixes;
if (defined $prefix) {
    @possible_prefixes = ($prefix);
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

undef $prefix;
foreach my $dir (@possible_prefixes) {
    if (-d "$dir/lib"
	and -d "$dir/share/sphinx2/model/hmm"
	and -d "$dir/share/sphinx2/model/lm") {
	$prefix = $dir;
	$sphinxdir = "$dir/share/sphinx2";
	last;
    }
}

unless (defined($sphinxdir)) {
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

print "Found Sphinx-II in $prefix and $sphinxdir\n";
unlink './SPX/Config.pm';
open CONFIG, ">./SPX/Config.pm"
    or die "can't open ./SPX/Config.pm: $!";
print CONFIG <<EOF;
package Speech::Recognizer::SPX;
\$PREFIX = '$prefix';
\$SPHINXDIR = '$sphinxdir';
1;
EOF
close CONFIG;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      NAME	   => 'Speech::Recognizer::SPX',
	      VERSION_FROM => 'SPX.pm',
	      LIBS	   => ["-L$prefix/lib -lsphinx2 -lsphinx2ad -lsphinx2fe -lm"],
	      OPTIMIZE     => '-g -O2',
	      # For Speech::Recognizer::SPX::Server
	      PREREQ_PM    => { 'Time::HiRes' => 0 },
	      clean        => { FILES => 'SPX/Config.pm' },
);
