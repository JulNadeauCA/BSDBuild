# Public domain

my $testCodeSSE = << 'EOF';
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

my $testCodeSSE2 = << 'EOF';
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

my $testCodeSSE3 = << 'EOF';
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

sub TEST_sse
{
	my ($ver) = @_;

	# XXX cross compiling

	MkDefine('SSE_CFLAGS', '-msse');
	MkCompileAndRunC('HAVE_SSE', '${CFLAGS} ${SSE_CFLAGS}', '', $testCodeSSE);

	MkPrintSN('checking for SSE2 extensions...');
	MkDefine('SSE2_CFLAGS', '-msse2');
	MkCompileAndRunC('HAVE_SSE2', '${CFLAGS} ${SSE2_CFLAGS}', '', $testCodeSSE2);
	
	MkPrintSN('checking for SSE3 extensions...');
	MkDefine('SSE3_CFLAGS', '-msse3');
	MkCompileAndRunC('HAVE_SSE3', '${CFLAGS} ${SSE3_CFLAGS}', '', $testCodeSSE3);
}

sub CMAKE_sse
{
	my $codeSSE = MkCodeCMAKE($testCodeSSE);
	my $codeSSE2 = MkCodeCMAKE($testCodeSSE2);
	my $codeSSE3 = MkCodeCMAKE($testCodeSSE3);

	return << "EOF";
macro(Check_SSE)
	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})

	set(CMAKE_REQUIRED_FLAGS "\${ORIG_CMAKE_REQUIRED_FLAGS} -msse")
	check_c_source_compiles("
$codeSSE" HAVE_SSE)
	if (HAVE_SSE)
		set(SSE_CFLAGS "-msse")
		BB_Save_MakeVar(SSE_CFLAGS "\${SSE_CFLAGS}")
		BB_Save_Define(HAVE_SSE)
	else()
		set(SSE_CFLAGS "")
		BB_Save_MakeVar(SSE_CFLAGS "")
		BB_Save_Undef(HAVE_SSE)
	endif()

	set(CMAKE_REQUIRED_FLAGS "\${ORIG_CMAKE_REQUIRED_FLAGS} -msse2")
	check_c_source_compiles("
$codeSSE2" HAVE_SSE2)
	if (HAVE_SSE2)
		set(SSE2_CFLAGS "-msse2")
		BB_Save_MakeVar(SSE2_CFLAGS "\${SSE2_CFLAGS}")
		BB_Save_Define(HAVE_SSE2)
	else()
		set(SSE2_CFLAGS "")
		BB_Save_MakeVar(SSE2_CFLAGS "")
		BB_Save_Undef(HAVE_SSE2)
	endif()

	set(CMAKE_REQUIRED_FLAGS "\${ORIG_CMAKE_REQUIRED_FLAGS} -msse3")
	check_c_source_compiles("
$codeSSE3" HAVE_SSE3)
	if (HAVE_SSE3)
		set(SSE3_CFLAGS "-msse3")
		BB_Save_MakeVar(SSE3_CFLAGS "\${SSE3_CFLAGS}")
		BB_Save_Define(HAVE_SSE3)
	else()
		set(SSE3_CFLAGS "")
		BB_Save_MakeVar(SSE3_CFLAGS "")
		BB_Save_Undef(HAVE_SSE3)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
endmacro()

macro(Disable_SSE)
	set(SSE_CFLAGS "")
	set(SSE2_CFLAGS "")
	set(SSE3_CFLAGS "")
	BB_Save_MakeVar(SSE_CFLAGS "")
	BB_Save_MakeVar(SSE2_CFLAGS "")
	BB_Save_MakeVar(SSE3_CFLAGS "")
	BB_Save_Undef(HAVE_SSE)
	BB_Save_Undef(HAVE_SSE2)
	BB_Save_Undef(HAVE_SSE3)
endmacro()
EOF
}

sub DISABLE_sse
{
	MkDefine('HAVE_SSE', 'no');
	MkDefine('HAVE_SSE2', 'no');
	MkDefine('HAVE_SSE3', 'no');
	MkDefine('INLINE_SSE', 'no');
	MkDefine('SSE_CFLAGS', '');
	MkDefine('SSE2_CFLAGS', '');
	MkDefine('SSE3_CFLAGS', '');
	MkSaveUndef('HAVE_SSE', 'HAVE_SSE2', 'HAVE_SSE3', 'INLINE_SSE');
}

BEGIN
{
	my $n = 'sse';

	$DESCR{$n}   = 'SSE extensions';
	$TESTS{$n}   = \&TEST_sse;
	$CMAKE{$n}   = \&CMAKE_sse;
	$DISABLE{$n} = \&DISABLE_sse;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'SSE_CFLAGS SSE2_CFLAGS SSE3_CFLAGS';
}
;1
