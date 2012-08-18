# vim:ts=4
#
# Copyright (c) 2007-2012 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sub Test
{
	my ($ver) = @_;

	MkDefine('SSE_CFLAGS', '-msse');
	# XXX cross compiling
	MkCompileAndRunC('HAVE_SSE', '${CFLAGS} ${SSE_CFLAGS}', '', << 'EOF');
#include <xmmintrin.h>
#include <stdio.h>

#define MAXERR 1e-4

typedef union vec {
	float v[4];
	__m128 m128;
	struct { float x, y, z, pad; };
} MyVector __attribute__ ((aligned(16)));

int
main(int argc, char *argv[])
{
	MyVector a;
	__m128 v;

	a.x = 1.0f;
	a.y = 2.0f;
	a.z = 3.0f;
	v = _mm_set1_ps(1.0f);
	a.m128 = _mm_mul_ps(a.m128, v);
	return (0);
}
EOF
	MkIfTrue('${HAVE_SSE}');
		MkSaveDefine('SSE_CFLAGS');
	MkElse;
		MkSaveUndef('SSE_CFLAGS');
		MkDefine('SSE_CFLAGS', '');
	MkEndif;
	MkSaveMK('SSE_CFLAGS');

	MkPrintN('checking for SSE2 extensions...');
	MkDefine('SSE2_CFLAGS', '-msse2');
	MkCompileAndRunC('HAVE_SSE2', '${CFLAGS} ${SSE2_CFLAGS}', '',
	    << 'EOF');
#include <emmintrin.h>

int
main(int argc, char *argv[])
{
	double a[4] __attribute__ ((aligned(16)));
	double b[4] __attribute__ ((aligned(16)));
	double rv;
	__m128d vec1, vec2;
	a[0] = 1.0f; a[1] = 2.0f; a[2] = 3.0f; a[3] = 4.0f;
	b[0] = 1.0f; b[1] = 2.0f; b[2] = 3.0f; b[3] = 4.0f;
	vec1 = _mm_load_pd(a);
	vec2 = _mm_load_pd(b);
	vec1 = _mm_xor_pd(vec1, vec2);
	_mm_store_sd(&rv, vec1);
	return (0);
}
EOF
	MkIfTrue('${HAVE_SSE2}');
		MkSaveDefine('SSE2_CFLAGS');
	MkElse;
		MkSaveUndef('SSE2_CFLAGS');
		MkDefine('SSE2_CFLAGS', '');
	MkEndif;
	MkSaveMK('SSE2_CFLAGS');
	
	MkPrintN('checking for SSE3 extensions...');
	MkDefine('SSE3_CFLAGS', '-msse3');
	MkCompileAndRunC('HAVE_SSE3', '${CFLAGS} ${SSE3_CFLAGS}', '',
	    << 'EOF');
#include <pmmintrin.h>

int
main(int argc, char *argv[])
{
	float a[4] __attribute__ ((aligned(16)));
	float b[4] __attribute__ ((aligned(16)));
	__m128 vec1, vec2;
	float rv;
	a[0] = 1.0f; a[1] = 2.0f; a[2] = 3.0f; a[3] = 4.0f;
	b[0] = 1.0f; b[1] = 2.0f; b[2] = 3.0f; b[3] = 4.0f;
	vec1 = _mm_load_ps(a);
	vec2 = _mm_load_ps(b);
	vec1 = _mm_mul_ps(vec1, vec2);
	vec1 = _mm_hadd_ps(vec1, vec1);
	vec1 = _mm_hadd_ps(vec1, vec1);
	_mm_store_ss(&rv, vec1);
	return (0);
}
EOF
	MkIfTrue('${HAVE_SSE3}');
		MkSaveDefine('SSE3_CFLAGS');
	MkElse;
		MkSaveUndef('SSE3_CFLAGS');
		MkDefine('SSE3_CFLAGS', '');
	MkEndif;
	MkSaveMK('SSE3_CFLAGS');
	
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('SSE', 'SSE2', 'SSE3');
	return (1);
}

BEGIN
{
	$DESCR{'sse'} = 'SSE extensions';
	$TESTS{'sse'} = \&Test;
	$EMUL{'sse'} = \&Emul;
	$DEPS{'sse'} = 'cc';
}

;1
