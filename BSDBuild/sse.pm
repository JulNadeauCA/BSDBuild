# Public domain
# vim:ts=4

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

	MkPrintSN('checking for SSE2 extensions...');
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
	
	MkPrintSN('checking for SSE3 extensions...');
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

sub Disable
{
	MkDefine('HAVE_SSE', 'no');
	MkDefine('HAVE_SSE2', 'no');
	MkDefine('HAVE_SSE3', 'no');
	MkDefine('INLINE_SSE', 'no');
	MkDefine('SSE_CFLAGS', '');
	MkDefine('SSE2_CFLAGS', '');
	MkDefine('SSE3_CFLAGS', '');

	MkSaveUndef('HAVE_SSE',
                'HAVE_SSE2',
                'HAVE_SSE3',
                'INLINE_SSE',
                'SSE_CFLAGS',
                'SSE2_CFLAGS',
                'SSE3_CFLAGS');
}

sub Emul
{
	Disable();
	return (1);
}

BEGIN
{
	my $n = 'sse';

	$DESCR{$n} = 'SSE extensions';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}

;1
