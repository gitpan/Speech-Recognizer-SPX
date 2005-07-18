use strict;

# Speech::Recognizer::SPX:  Perl interface to the Sphinx-II speech recognizer.

# Copyright (c) 2000 Cepstral LLC.
#
# This module is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# Written by David Huggins-Daines <dhuggins@cs.cmu.edu>

package Speech::Recognizer::SPX;
use Carp;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);

require Exporter;
require DynaLoader;
require Speech::Recognizer::SPX::Config;

@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(
		fbs_init
		fbs_end

		uttfile_open
		uttproc_begin_utt
		uttproc_rawdata
		uttproc_cepdata
		uttproc_end_utt
		uttproc_abort_utt
		uttproc_stop_utt
		uttproc_restart_utt
		uttproc_result
		uttproc_partial_result
		uttproc_get_uttid
		uttproc_set_auto_uttid_prefix
		uttproc_set_lm
		uttproc_lmupdate
		uttproc_set_context
		uttproc_set_rawlogdir
		uttproc_set_mfclogdir
		uttproc_set_logfile

		lm_read
		lm_delete

		BG_SEG_SZ
		LM3G_ACCESS_BG
		LM3G_ACCESS_ERR
		LM3G_ACCESS_TG
		LM3G_ACCESS_UG
		LOG_BG_SEG_SZ
		NO_WORD
		NUM_COEFF
		NUM_SMOOTH
		OFFSET_LIKELIHOOD
		SPHINXP_PORT

		$SPHINXDIR
);
%EXPORT_TAGS = (
		fbs => [qw(
			   fbs_init
			   fbs_end
			  )
		       ],
		uttproc => [qw(
			       uttfile_open
			       uttproc_begin_utt
			       uttproc_rawdata
			       uttproc_cepdata
			       uttproc_end_utt
			       uttproc_abort_utt
			       uttproc_stop_utt
			       uttproc_restart_utt
			       uttproc_result
			       uttproc_partial_result
			       uttproc_get_uttid
			       uttproc_set_auto_uttid_prefix
			       uttproc_set_lm
			       uttproc_lmupdate
			       uttproc_set_context
			       uttproc_set_rawlogdir
			       uttproc_set_mfclogdir
			       uttproc_set_logfile
			      )
			   ],
		lm => [
		       qw(
			  lm_read
			  lm_delete
			 )
		      ],
	       );

$VERSION = 0.07_01;

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    croak "Undefined subroutine $AUTOLOAD";
	}
	else {
	    croak "Your vendor has not defined Speech::Recognizer::SPX macro $constname";
	}
    }
    no strict 'refs';
    if ($] >= 5.00561) {
	*$AUTOLOAD = sub () { $val };
    } else {
	*$AUTOLOAD = sub { $val };
    }
    goto &$AUTOLOAD;
}

bootstrap Speech::Recognizer::SPX $VERSION;

1;
__END__

=head1 NAME

Speech::Recognizer::SPX - Perl extension for the Sphinx2 speech recognizer

=head1 SYNOPSIS

  use Speech::Recognizer::SPX qw(:fbs :uttproc)
  fbs_init([arg1 => $val, arg2 => $val, ...]);
  uttproc_begin_utt();
  uttproc_end_utt();
  fbs_end();

=head1 DESCRIPTION

This module provides a Perl interface to the Sphinx-II speech
recognizer library.

Warning!  This interface is subject to change.  It's currently a bit
clunky because of the way the Sphinx-II library is structured, and
that will probably change (for the better, I hope) over time.

When the interface changes, future versions of this documentation will
point out how it has changed and how to deal with this.

=head1 USING THIS MODULE

  use Speech::Recognizer::SPX qw(:fbs :uttproc :lm);

Because most parts of the Sphinx-II library contain a lot of global
internal state, it makes no sense to use an object-oriented interface
at this time.  However I don't want to clobber your namespace with a
billion functions you may or may not use.  To make things easier on
your typing hands, the available functions have been grouped in to
tags representing modules inside the library itself.  These tags and
the functions they import are listed below.

=over 4

=item C<:fbs>

This is somewhat of a misnomer - FBS stands for Fast Beam Search, but
in actual fact this module (the fbs_main.c file in Sphinx-II) just
wraps around the other modules in sphinx (one of which actually does
fast beam search :-) and initializes the recognizer for you.
Functions imported by this tag are:

  fbs_init
  fbs_end

=item C<:uttproc>

This is the utterance processing module.  You feed it data (either raw
audio data or feature data - which currently means vectors of
mel-frequency cepstral coefficients), and it feeds back search
hypotheses based on a language model.  Functions imported by this tag
are:

  uttfile_open
  uttproc_begin_utt
  uttproc_rawdata
  uttproc_cepdata
  uttproc_end_utt
  uttproc_abort_utt
  uttproc_stop_utt
  uttproc_restart_utt
  uttproc_result
  uttproc_partial_result
  uttproc_get_uttid
  uttproc_set_auto_uttid_prefix
  uttproc_set_lm
  uttproc_lmupdate
  uttproc_set_context
  uttproc_set_rawlogdir
  uttproc_set_mfclogdir
  uttproc_set_logfile

=item C<:lm>

This is the language model module.  It loads and unloads language models.

  lm_read
  lm_delete

=back

=head1 STARTUP

  fbs_init(\@args);

The C<fbs_init> function is the main entry point to the Sphinx
library.  If given no arguments, it will snarf options from the global
C<@ARGV> array (because that's what its C equivalent does).  To make
life easier, and to entice people to write Sphinx programs in Perl
instead of C, we also give you a way around this by allowing you to
also pass a reference to an array whose contents are arranged in the
same way C<@ARGV> might be, i.e. a list of option/value pairs.

To make things pretty, you can use the magical => operator, like this:

  fbs_init([samp => 16000,
            datadir => '/foo/bar/baz']);

Note that you can omit the leading dash from argument names (if you
like).

Calling this function will block your process for a long time and
print unbelievable amounts of debugging gunk to STDOUT and STDERR.
This will get better eventually.

This function has a large number of options.  Someday they will be
documented.  Until then, either look in the example code, or go
straight to the source, namely the C<param> variable in
C<src/libsphinx2/fbs_main.c> and the C<kb_param> variable in
C<src/libsphinx2/kb_main.c>.

=head1 FEED ME

  uttproc_begin_utt() or die;
  uttproc_rawdata($buf [, $block]) or die;
  uttproc_cepdata(\@cepvecs [, $block]) or die;
  uttproc_end_utt() or die;

To actually recognize some speech data, you use the functions exported
by the C<:uttproc> tag.  Before calling any of them, you must
successfully call C<uttproc_begin_utt>, or Bad Things are certain to
happen (I can't speculate on exactly what things, but I'm sure they're
bad).

You should call C<uttproc_begin_utt> before each distinct utterance
(to the extent that you can predict when individual utterances begin
or end, of course...), and C<uttproc_end_utt> at the end of each.

After calling C<uttproc_begin_utt>, you can pass either raw audio data
or cepstral feature vectors (see L<Audio::MFCC>), using
C<uttproc_rawdata> or C<uttproc_cepdata>, respectively.  Due to the
way feature extraction works, you cannot mix the two types of data
within the same utterance.

If live mode is in effect (i.e. C<-livemode => TRUE> was passed to
C<fbs_init>), the optional C<$block> parameter controls whether these
functions will return immediately after processing a single frame of
data, or whether they will process all pending frames of data.  If you
need partial results, you probably want to pass a non-zero value
(FIXME: should be a true value but I don't know how to test for truth
in XS code) for C<$block>, though this may increase latency elsewhere
in the system.

Unfortunately, it appears that there is no specific function to flush
all unprocessed frames before getting a partial result.  Calling
uttproc_rawdata with an empty C<$buf> and C<$block> non-zero seems to
have the desired effect.

=head1 GETTING RESULTS

  my ($frames, $hypothesis) = uttproc_result($block);
  my ($frames, $hypothesis) = uttproc_partial_result();

At any point during utterance processing, you may call
C<uttproc_partial_result> to obtain the current "best guess".  Note
that this function does B<not> flush unprocessed frames, so you might
want to use the trick mentioned above to do so before calling it if
you are operating in non-blocking mode.

By contrast, you may not call C<uttproc_result> until after you have
called C<uttproc_end_utt> (or C<uttproc_abort_utt> or also possibly
C<uttproc_stop_utt>).  The C<$block> flag is also optional here, but I
strongly suggest you use it.

=head1 FIDDLY BITS

Changing language models, etc, etc...  This documentation is under
construction.

=head1 EXAMPLES

For now there are just some example programs in the distribution.

=head1 AUTHOR

David Huggins-Daines <dhuggins@cs.cmu.edu>

=head1 SEE ALSO

perl(1), L<Speech::Recognizer::SPX::Server>, L<Audio::SPX>, L<Audio::MFCC>

=cut
