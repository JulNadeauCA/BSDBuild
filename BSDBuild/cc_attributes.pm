# Public domain
# vim:ts=4

sub Test_CC_Attributes
{
	$Quiet = 1;

	TryCompileFlagsC('HAVE_ALIGNED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { int x,y,z; } __attribute__ ((aligned(16)));
	return (0);
}
EOF
	MkIfTrue('${HAVE_ALIGNED_ATTRIBUTE}');
		MkPrintSN('aligned ');
	MkElse;
		MkPrintSN('!aligned ');
	MkEndif;

	MkCompileC('HAVE_BOUNDED_ATTRIBUTE', '', '', << 'EOF');
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
	MkIfTrue('${HAVE_BOUNDED_ATTRIBUTE}');
		MkPrintSN('bounded ');
	MkElse;
		MkPrintSN('!bounded ');
	MkEndif;

	TryCompileFlagsC('HAVE_CONST_ATTRIBUTE', '', << 'EOF');
int foo(int) __attribute__ ((const));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF
	MkIfTrue('${HAVE_CONST_ATTRIBUTE}');
		MkPrintSN('const ');
	MkElse;
		MkPrintSN('!const ');
	MkEndif;

	TryCompileFlagsC('HAVE_DEPRECATED_ATTRIBUTE', '', << 'EOF');
void foo(void) __attribute__ ((deprecated));
void foo(void) { }

int main(int argc, char *argv[])
{
/*	foo(); */
	return (0);
}
EOF
	MkIfTrue('${HAVE_DEPRECATED_ATTRIBUTE}');
		MkPrintSN('deprecated ');
	MkElse;
		MkPrintSN('!deprecated ');
	MkEndif;

	MkCompileC('HAVE_FORMAT_ATTRIBUTE', '', '', << 'EOF');
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
	MkIfTrue('${HAVE_FORMAT_ATTRIBUTE}');
		MkPrintS('format');
	MkElse;
		MkPrintS('!format');
	MkEndif;
	
	MkPrintSN('checking for C compiler attributes...');

	TryCompileFlagsC('HAVE_MALLOC_ATTRIBUTE', '', << 'EOF');
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
	MkIfTrue('${HAVE_MALLOC_ATTRIBUTE}');
		MkPrintSN('malloc ');
	MkElse;
		MkPrintSN('!malloc ');
	MkEndif;

	TryCompileFlagsC('HAVE_NORETURN_ATTRIBUTE', '', << 'EOF');
#include <unistd.h>
#include <stdlib.h>
void foo(void) __attribute__ ((noreturn));
void foo(void) { _exit(0); }
int main(int argc, char *argv[])
{
	foo();
}
EOF
	MkIfTrue('${HAVE_NORETURN_ATTRIBUTE}');
		MkPrintSN('noreturn ');
	MkElse;
		MkPrintSN('!noreturn ');
	MkEndif;

	TryCompileFlagsC('HAVE_PACKED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { char c; int x,y,z; } __attribute__ ((packed));
	return (0);
}
EOF
	MkIfTrue('${HAVE_PACKED_ATTRIBUTE}');
		MkPrintSN('packed ');
	MkElse;
		MkPrintSN('!packed ');
	MkEndif;

	TryCompileFlagsC('HAVE_PURE_ATTRIBUTE', '', << 'EOF');
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
	MkIfTrue('${HAVE_PURE_ATTRIBUTE}');
		MkPrintSN('pure ');
	MkElse;
		MkPrintSN('!pure ');
	MkEndif;
	
	TryCompileFlagsC('HAVE_UNUSED_VARIABLE_ATTRIBUTE', '', << 'EOF');
int main(int argc, char *argv[])
{
	int __attribute__ ((unused)) variable;
	return (0);
}
EOF
	MkIfTrue('${HAVE_UNUSED_VARIABLE_ATTRIBUTE}');
		MkPrintS('unused');
	MkElse;
		MkPrintS('!unused');
	MkEndif;
	
	MkPrintSN('checking for C compiler attributes...');

	TryCompileFlagsC('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE', '', << 'EOF');
int foo(void) __attribute__ ((warn_unused_result));
int foo(void) { return (1); }
int main(int argc, char *argv[])
{
	int rv = foo();
	return (rv);
}
EOF
	MkIfTrue('${HAVE_WARN_UNUSED_RESULT_ATTRIBUTE}');
		MkPrintS('warn_unused_result ');
	MkElse;
		MkPrintS('!warn_unused_result ');
	MkEndif;

	$Quiet = 0;
}

sub Disable_CC_Attributes
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

sub Emul
{
	Disable_CC_Attributes();
	return (1);
}

BEGIN
{
	my $n = 'cc_attributes';

	$DESCR{$n}   = 'C compiler attributes';

	$TESTS{$n}   = \&Test_CC_Attributes;
	$DISABLE{$n} = \&Disable_CC_Attributes;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n}    = 'cc';
}

;1
