# Public domain

my $testCodeAligned = << 'EOF';
int main(int argc, char *argv[])
{
	struct s1 { int x,y,z; } __attribute__ ((aligned(16)));
	return (0);
}
EOF

my $testCodeBounded = << 'EOF';
void foostring(char *, int) __attribute__ ((__bounded__(__string__,1,2)));
void foostring(char *a, int c) { }
void foobuffer(void *, int) __attribute__ ((__bounded__(__buffer__,1,2)));
void foobuffer(void *a, int c) { }
int main(void)
{
	char buf[32];
	foostring(buf, sizeof(buf));
	foobuffer(buf, sizeof(buf));
	return (0);
}
EOF

my $testCodeConst = << 'EOF';
int foo(int) __attribute__ ((const));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF

my $testCodeDeprecated = << 'EOF';
void foo(void) __attribute__ ((deprecated));
void foo(void) { }

int main(int argc, char *argv[])
{
/*	foo(); */
	return (0);
}
EOF

my $testCodeFormat = << 'EOF';
#include <stdarg.h>
void foo1(char *, ...)
     __attribute__((__format__ (printf, 1, 2)));
void foo2(char *, ...)
     __attribute__((__format__ (__printf__, 1, 2)));
void foo1(char *a, ...) {}
void foo2(char *a, ...) {}
int main(int argc, char *argv[])
{
	foo1("foo %s", "bar");
	foo2("foo %d", 1);
	return (0);
}
EOF

my $testCodeMalloc = << 'EOF';
#include <stdio.h>
#include <stdlib.h>

void *myalloc(size_t len) __attribute__ ((__malloc__));
void *myalloc(size_t len) { return (NULL); }
int main(int argc, char *argv[])
{
	void *p = myalloc(10);
	return (p != NULL);
}
EOF

my $testCodeNoReturn = << 'EOF';
#include <unistd.h>
#include <stdlib.h>
void foo(void) __attribute__ ((noreturn));
void foo(void) { _exit(0); }
int main(int argc, char *argv[])
{
	foo();
}
EOF

my $testCodePacked = << 'EOF';
int main(int argc, char *argv[])
{
	struct s1 { char c; int x,y,z; } __attribute__ ((packed));
	return (0);
}
EOF

my $testCodePure = << 'EOF';
volatile int glo = 1234;
int foo(int) __attribute__ ((pure));
int foo(int x) { return (x*x + glo); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	glo = 2345;
	x = foo(2);
	return (x);
}
EOF

my $testCodeUnusedVariable = << 'EOF';
int main(int argc, char *argv[])
{
	int __attribute__ ((unused)) variable;
	return (0);
}
EOF

my $testCodeWarnUnusedResult = << 'EOF';
int foo(void) __attribute__ ((warn_unused_result));
int foo(void) { return (1); }
int main(int argc, char *argv[])
{
	int rv = foo();
	return (rv);
}
EOF

sub TEST_cc_attributes
{
	$Quiet = 1;

	TryCompileFlagsC('HAVE_ALIGNED_ATTRIBUTE', '-Wall -Werror', $testCodeAligned);
	MkIfTrue('${HAVE_ALIGNED_ATTRIBUTE}');
		MkPrintSN('aligned ');
	MkElse;
		MkPrintSN('!aligned ');
	MkEndif;

	MkCompileC('HAVE_BOUNDED_ATTRIBUTE', '', '', $testCodeBounded);
	MkIfTrue('${HAVE_BOUNDED_ATTRIBUTE}');
		MkPrintSN('bounded ');
	MkElse;
		MkPrintSN('!bounded ');
	MkEndif;

	TryCompileFlagsC('HAVE_CONST_ATTRIBUTE', '-Wall -Werror', $testCodeConst);
	MkIfTrue('${HAVE_CONST_ATTRIBUTE}');
		MkPrintSN('const ');
	MkElse;
		MkPrintSN('!const ');
	MkEndif;

	TryCompileFlagsC('HAVE_DEPRECATED_ATTRIBUTE', '-Wall -Werror', $testCodeDeprecated);
	MkIfTrue('${HAVE_DEPRECATED_ATTRIBUTE}');
		MkPrintSN('deprecated ');
	MkElse;
		MkPrintSN('!deprecated ');
	MkEndif;

	MkCompileC('HAVE_FORMAT_ATTRIBUTE', '', '', $testCodeFormat);
	MkIfTrue('${HAVE_FORMAT_ATTRIBUTE}');
		MkPrintS('format');
	MkElse;
		MkPrintS('!format');
	MkEndif;
	
	MkPrintSN('checking for C compiler attributes...');

	TryCompileFlagsC('HAVE_MALLOC_ATTRIBUTE', '-Wall -Werror', $testCodeMalloc);
	MkIfTrue('${HAVE_MALLOC_ATTRIBUTE}');
		MkPrintSN('malloc ');
	MkElse;
		MkPrintSN('!malloc ');
	MkEndif;

	TryCompileFlagsC('HAVE_NORETURN_ATTRIBUTE', '-Wall -Werror', $testCodeNoReturn);
	MkIfTrue('${HAVE_NORETURN_ATTRIBUTE}');
		MkPrintSN('noreturn ');
	MkElse;
		MkPrintSN('!noreturn ');
	MkEndif;

	TryCompileFlagsC('HAVE_PACKED_ATTRIBUTE', '-Wall -Werror', $testCodePacked);
	MkIfTrue('${HAVE_PACKED_ATTRIBUTE}');
		MkPrintSN('packed ');
	MkElse;
		MkPrintSN('!packed ');
	MkEndif;

	TryCompileFlagsC('HAVE_PURE_ATTRIBUTE', '-Wall -Werror', $testCodePure);
	MkIfTrue('${HAVE_PURE_ATTRIBUTE}');
		MkPrintSN('pure ');
	MkElse;
		MkPrintSN('!pure ');
	MkEndif;
	
	TryCompileFlagsC('HAVE_UNUSED_VARIABLE_ATTRIBUTE', '-Wall -Werror', $testCodeUnusedVariable);
	MkIfTrue('${HAVE_UNUSED_VARIABLE_ATTRIBUTE}');
		MkPrintS('unused');
	MkElse;
		MkPrintS('!unused');
	MkEndif;
	
	MkPrintSN('checking for C compiler attributes...');

	TryCompileFlagsC('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE', '-Wall -Werror', $testCodeWarnUnusedResult);
	MkIfTrue('${HAVE_WARN_UNUSED_RESULT_ATTRIBUTE}');
		MkPrintS('warn_unused_result ');
	MkElse;
		MkPrintS('!warn_unused_result ');
	MkEndif;

	$Quiet = 0;
}

sub DISABLE_cc_attributes
{
	MkSaveUndef('HAVE_ALIGNED_ATTRIBUTE');
	MkSaveUndef('HAVE_BOUNDED_ATTRIBUTE');
	MkSaveUndef('HAVE_CONST_ATTRIBUTE');
	MkSaveUndef('HAVE_DEPRECATED_ATTRIBUTE');
	MkSaveUndef('HAVE_FORMAT_ATTRIBUTE');
	MkSaveUndef('HAVE_MALLOC_ATTRIBUTE');
	MkSaveUndef('HAVE_NORETURN_ATTRIBUTE');
	MkSaveUndef('HAVE_PACKED_ATTRIBUTE');
	MkSaveUndef('HAVE_PURE_ATTRIBUTE');
	MkSaveUndef('HAVE_UNUSED_VARIABLE_ATTRIBUTE');
	MkSaveUndef('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE');
}

sub CMAKE_cc_attributes
{
	my $codeAligned = MkCodeCMAKE($testCodeAligned);
	my $codeBounded = MkCodeCMAKE($testCodeBounded);
	my $codeConst = MkCodeCMAKE($testCodeConst);
	my $codeDeprecated = MkCodeCMAKE($testCodeDeprecated);
	my $codeFormat = MkCodeCMAKE($testCodeFormat);
	my $codeMalloc = MkCodeCMAKE($testCodeMalloc);
	my $codeNoReturn = MkCodeCMAKE($testCodeNoReturn);
	my $codePacked = MkCodeCMAKE($testCodePacked);
	my $codePure = MkCodeCMAKE($testCodePure);
	my $codeUnusedVariable = MkCodeCMAKE($testCodeUnusedVariable);
	my $codeWarnUnusedResult = MkCodeCMAKE($testCodeWarnUnusedResult);

	return << "EOF";
macro(Check_Cc_Attributes)
	set(ORIG_CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS}")
	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -Wall -Werror")

	check_c_source_compiles("
$codeAligned" HAVE_ALIGNED_ATTRIBUTE)
	if (HAVE_ALIGNED_ATTRIBUTE)
		BB_Save_Define(HAVE_ALIGNED_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_ALIGNED_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeBounded" HAVE_BOUNDED_ATTRIBUTE)
	if (HAVE_BOUNDED_ATTRIBUTE)
		BB_Save_Define(HAVE_BOUNDED_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_BOUNDED_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeConst" HAVE_CONST_ATTRIBUTE)
	if (HAVE_CONST_ATTRIBUTE)
		BB_Save_Define(HAVE_CONST_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_CONST_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeDeprecated" HAVE_DEPRECATED_ATTRIBUTE)
	if (HAVE_DEPRECATED_ATTRIBUTE)
		BB_Save_Define(HAVE_DEPRECATED_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_DEPRECATED_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeFormat" HAVE_FORMAT_ATTRIBUTE)
	if (HAVE_FORMAT_ATTRIBUTE)
		BB_Save_Define(HAVE_FORMAT_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_FORMAT_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeMalloc" HAVE_MALLOC_ATTRIBUTE)
	if (HAVE_MALLOC_ATTRIBUTE)
		BB_Save_Define(HAVE_MALLOC_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_MALLOC_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeNoReturn" HAVE_NORETURN_ATTRIBUTE)
	if (HAVE_NORETURN_ATTRIBUTE)
		BB_Save_Define(HAVE_NORETURN_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_NORETURN_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codePacked" HAVE_PACKED_ATTRIBUTE)
	if (HAVE_PACKED_ATTRIBUTE)
		BB_Save_Define(HAVE_PACKED_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_PACKED_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codePure" HAVE_PURE_ATTRIBUTE)
	if (HAVE_PURE_ATTRIBUTE)
		BB_Save_Define(HAVE_PURE_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_PURE_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeUnusedVariable" HAVE_UNUSED_VARIABLE_ATTRIBUTE)
	if (HAVE_UNUSED_VARIABLE_ATTRIBUTE)
		BB_Save_Define(HAVE_UNUSED_VARIABLE_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_UNUSED_VARIABLE_ATTRIBUTE)
	endif()

	check_c_source_compiles("
$codeWarnUnusedResult" HAVE_WARN_UNUSED_RESULT_ATTRIBUTE)
	if (HAVE_WARN_UNUSED_RESULT_ATTRIBUTE)
		BB_Save_Define(HAVE_WARN_UNUSED_RESULT_ATTRIBUTE)
	else()
		BB_Save_Undef(HAVE_WARN_UNUSED_RESULT_ATTRIBUTE)
	endif()

	set(CMAKE_REQUIRED_FLAGS "\${ORIG_CMAKE_REQUIRED_FLAGS}")
endmacro()

macro(Disable_Cc_Attributes)
	BB_Save_Undef(HAVE_ALIGNED_ATTRIBUTE)
	BB_Save_Undef(HAVE_BOUNDED_ATTRIBUTE)
	BB_Save_Undef(HAVE_CONST_ATTRIBUTE)
	BB_Save_Undef(HAVE_DEPRECATED_ATTRIBUTE)
	BB_Save_Undef(HAVE_FORMAT_ATTRIBUTE)
	BB_Save_Undef(HAVE_MALLOC_ATTRIBUTE)
	BB_Save_Undef(HAVE_NORETURN_ATTRIBUTE)
	BB_Save_Undef(HAVE_PACKED_ATTRIBUTE)
	BB_Save_Undef(HAVE_PURE_ATTRIBUTE)
	BB_Save_Undef(HAVE_UNUSED_VARIABLE_ATTRIBUTE)
	BB_Save_Undef(HAVE_WARN_UNUSED_RESULT_ATTRIBUTE)
endmacro()
EOF
}

BEGIN
{
	my $n = 'cc_attributes';

	$DESCR{$n}   = 'C compiler attributes';
	$TESTS{$n}   = \&TEST_cc_attributes;
	$CMAKE{$n}   = \&CMAKE_cc_attributes;
	$DISABLE{$n} = \&DISABLE_cc_attributes;
	$DEPS{$n}    = 'cc';
}
;1
