/*
 * Audio.xs: Perl interface to the Sphinx-II audio library
 *
 *
 * Copyright (c) 2000 Cepstral LLC.
 *
 * This module is free software; you can redistribute it and/or modify
 * it under the same terms as Perl itself.
 *
 * Written by David Huggins-Daines <dhd@cepstral.com>
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <unistd.h>

#include <sphinx2/s2types.h>
#include <sphinx2/ad.h>
#include <sphinx2/cont_ad.h>

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(char *name, int arg)
{
    errno = 0;
    switch (*name) {
    case 'A':
	if (strEQ(name, "AD_EOF"))
#ifdef AD_EOF
	    return AD_EOF;
#else
	    goto not_there;
#endif
	if (strEQ(name, "AD_ERR_GEN"))
#ifdef AD_ERR_GEN
	    return AD_ERR_GEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "AD_ERR_NOT_OPEN"))
#ifdef AD_ERR_NOT_OPEN
	    return AD_ERR_NOT_OPEN;
#else
	    goto not_there;
#endif
	if (strEQ(name, "AD_ERR_WAVE"))
#ifdef AD_ERR_WAVE
	    return AD_ERR_WAVE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "AD_OK"))
#ifdef AD_OK
	    return AD_OK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "AD_SAMPLE_SIZE"))
#ifdef AD_SAMPLE_SIZE
	    return AD_SAMPLE_SIZE;
#else
	    goto not_there;
#endif
	break;
    case 'B':
	break;
    case 'C':
	break;
    case 'D':
	if (strEQ(name, "DEFAULT_SAMPLES_PER_SEC"))
#ifdef DEFAULT_SAMPLES_PER_SEC
	    return DEFAULT_SAMPLES_PER_SEC;
#else
	    goto not_there;
#endif
	break;
    case 'E':
	break;
    case 'F':
	break;
    case 'G':
	break;
    case 'H':
	break;
    case 'I':
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	break;
    case 'N':
	break;
    case 'O':
	break;
    case 'P':
	break;
    case 'Q':
	break;
    case 'R':
	break;
    case 'S':
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    case 'a':
	break;
    case 'b':
	break;
    case 'c':
	break;
    case 'd':
	break;
    case 'e':
	break;
    case 'f':
	break;
    case 'g':
	break;
    case 'h':
	break;
    case 'i':
	break;
    case 'j':
	break;
    case 'k':
	break;
    case 'l':
	break;
    case 'm':
	break;
    case 'n':
	break;
    case 'o':
	break;
    case 'p':
	break;
    case 'q':
	break;
    case 'r':
	break;
    case 's':
	break;
    case 't':
	break;
    case 'u':
	break;
    case 'v':
	break;
    case 'w':
	break;
    case 'x':
	break;
    case 'y':
	break;
    case 'z':
	break;
    case '_':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

int ad_nbfh_read(ad_rec_t *ad, int16 *buf, int32 max)
{
	int fd = ad->dspFD; /* Linux specific */
	ssize_t bytes;
	int16 *cur = buf;

	bytes = read(fd, cur, max * sizeof(int16));

	if (bytes < 0) {
		if (errno != EAGAIN)
			croak("ad_pipe_read: error reading audio: %s\n",
			      strerror(errno));
		else
			bytes = 0;
	}

	if (0) {
		if (bytes) {
			static long seq;
			struct timeval tv;
			gettimeofday(&tv, NULL);
			fprintf(stderr, "ad_pipe_read: read %d samples (wanted %d),"
				" times are %ld:%ld seq %ld\n",
				bytes / ad->bps, max, tv.tv_sec, tv.tv_usec, seq);
			seq += bytes;
		}
	} /* 0 */

	return bytes / ad->bps;
}

typedef int32 SYSRET;

MODULE = Audio::SPX	PACKAGE = Audio::SPX	PREFIX = ad_

double
constant(name,arg)
	char *		name
	int		arg

ad_rec_t *
ad_open(class)
	SV *		class
	CODE:
		RETVAL = ad_open();
	OUTPUT:
		RETVAL

ad_rec_t *
ad_open_sps(class, samples)
	SV *		class
	int		samples
	CODE:
		RETVAL = ad_open_sps(samples);
	OUTPUT:
		RETVAL

MODULE = Audio::SPX	PACKAGE = ad_rec_tPtr	PREFIX = ad_

SYSRET
ad_start_rec(ad)
	ad_rec_t *	ad

SYSRET
ad_stop_rec(ad)
	ad_rec_t *	ad

SYSRET
ad_close(ad)
	ad_rec_t *	ad

SYSRET
ad_DESTROY(ad)
	ad_rec_t *	ad
	CODE:
		RETVAL = ad_close(ad);
	OUTPUT:
		RETVAL

SYSRET
ad_read(ad, buf, max)
	ad_rec_t *	ad
	SV *		buf
	int32		max
	PREINIT:
		STRLEN dummy;
	CODE:
		if (!SvPOK(buf)) {
			sv_setpv(buf, "");
		}
		SvGROW(buf, max * sizeof(int16));
		RETVAL = ad_read(ad, (int16 *) SvPV(buf, dummy), max);
		if (RETVAL != -1) {
			SvCUR_set(buf, RETVAL * sizeof(int16));
		} else {
			perror("ad_read returned -1");
		}
	OUTPUT:
		RETVAL
		buf

MODULE = Audio::SPX	PACKAGE = Audio::SPX::Continuous		PREFIX = cont_ad_

cont_ad_t *
cont_ad_init(class, ad)
	SV *		class
	ad_rec_t *	ad
	CODE:
		RETVAL = cont_ad_init(ad, ad_read);
	OUTPUT:
		RETVAL

cont_ad_t *
cont_ad_init_nbfh(class, fh, sps=16000)
	SV *		class
	FILE *		fh
	int		sps
	PREINIT:
		ad_rec_t *ad;
	CODE:
#ifdef AD_BACKEND_OSS
		/* FIXME: memory leak here. */
		Newz(99, ad, 1, ad_rec_t);

		/* Linux/OSS specific, unfortunately */
		ad->dspFD = fileno(fh);
		ad->sps = sps;
		/* FIXME: should not be hardcoded */
		ad->bps = sizeof(int16);
		RETVAL = cont_ad_init(ad, ad_nbfh_read);
#else
		croak("init_nbfh is not supported on this platform, due to Sphinx-II interface misdesign");
		RETVAL = NULL;
#endif
	OUTPUT:
		RETVAL

# Take advantage of undocumented features of cont_ad_read() to give a
# raw-data way of reading data to be filtered.

cont_ad_t *
cont_ad_init_raw(class, sps=16000)
	SV *		class
	int		sps
	PREINIT:
		ad_rec_t foo;
	CODE:
		/* "Have you no TASTE?" - Linus Torvalds */
		memset(&foo, 0, sizeof(foo));
		foo.sps = sps; /* If it has no 'sps' field, you're really screwed. */
		RETVAL = cont_ad_init(&foo, NULL);
		/* We only used 'foo' to get $#%#@$% cont_ad_init to pick
		   the right value for samples per second.  That, and
		   it's an auto variable.  This will make sure that no
		   references to it remain. */
		cont_ad_detach(RETVAL);
	OUTPUT:
		RETVAL

MODULE = Audio::SPX	PACKAGE = cont_ad_tPtr	PREFIX = cont_ad_

SYSRET
cont_ad_calib(cont)
	cont_ad_t *	cont

SYSRET
cont_ad_calib_loop(r, buf)
	cont_ad_t *	r
	SV *		buf
	PREINIT:
		int32	max;
	CODE:
		max = SvCUR(buf) / 2;
		RETVAL = cont_ad_calib_loop(r, (int16 *)SvPV(buf, PL_na), max);
	OUTPUT:
		RETVAL

SYSRET
cont_ad_read(ad, buf, max)
	cont_ad_t *	ad
	SV *		buf
	int32		max
	PREINIT:
		STRLEN dummy;
	CODE:
		if (!SvPOK(buf)) {
			sv_setpv(buf, "");
		}
		SvGROW(buf, max * sizeof(int16));
		RETVAL = cont_ad_read(ad, (int16 *)SvPV(buf, dummy), max);
		if (RETVAL != -1) {
			SvCUR_set(buf, RETVAL * sizeof(int16));
		}
	OUTPUT:
		RETVAL
		buf

SYSRET
cont_ad_set_thresh(cont, sil, sp)
	cont_ad_t *	cont
	int32		sil
	int32		sp

SYSRET
cont_ad_set_params(cont, delta_sil, delta_speech, min_noise, max_noise, winsize, speech_onset, sil_onset, leader, trailer)
	cont_ad_t *	cont
	int32		delta_sil
	int32		delta_speech
	int32		min_noise
	int32		max_noise
	int32		winsize
	int32		speech_onset
	int32		sil_onset
	int32		leader
	int32		trailer

void
cont_ad_get_params(cont)
	cont_ad_t *	cont
	PREINIT:
		int32	res, delta_sil, delta_speech, min_noise, max_noise,
			winsize, speech_onset, sil_onset, leader, trailer;
	PPCODE:
		res = cont_ad_get_params(cont, &delta_sil, &delta_speech,
					 &min_noise, &max_noise,
					 &winsize, &speech_onset,
					 &sil_onset, &leader, &trailer);
		if (res == -1)
			return; /* empty list */
		EXTEND(SP, 9);
		PUSHs(sv_2mortal(newSViv(delta_sil)));
		PUSHs(sv_2mortal(newSViv(delta_speech)));
		PUSHs(sv_2mortal(newSViv(min_noise)));
		PUSHs(sv_2mortal(newSViv(max_noise)));
		PUSHs(sv_2mortal(newSViv(winsize)));
		PUSHs(sv_2mortal(newSViv(speech_onset)));
		PUSHs(sv_2mortal(newSViv(sil_onset)));
		PUSHs(sv_2mortal(newSViv(leader)));
		PUSHs(sv_2mortal(newSViv(trailer)));

SYSRET
cont_ad_reset(cont)
	cont_ad_t *	cont

SYSRET
cont_ad_close(cont)
	cont_ad_t *	cont

SYSRET
cont_ad_DESTROY(cont)
	cont_ad_t *	cont
	CODE:
		RETVAL = cont_ad_close(cont);
	OUTPUT:
		RETVAL

SYSRET
cont_ad_detach(cont)
	cont_ad_t *	cont

SYSRET
cont_ad_attach(c, a)
	cont_ad_t *	c
	ad_rec_t *	a
	CODE:
		RETVAL = cont_ad_attach(c, a, ad_read);
	OUTPUT:
		RETVAL

int32
cont_ad_read_ts(c)
	cont_ad_t *	c
	CODE:
		RETVAL = c->read_ts;
	OUTPUT:
		RETVAL

void
cont_ad_set_logfp(fp)
	FILE *		fp
