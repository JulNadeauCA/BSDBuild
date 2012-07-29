# vim:ts=4
#
# Copyright (c) 2002-2012 Hypertriton, Inc. <http://hypertriton.com/>
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
		TryCompileFlagsC('HAVE_ALIGNED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { int x,y,z; } __attribute__ ((aligned(16)));
	return (0);
}
EOF

		MkPrintN('checking for __bounded__ attribute...');
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
	
		MkPrintN('checking for const attribute...');
		TryCompileFlagsC('HAVE_CONST_ATTRIBUTE', '', << 'EOF');
int foo(int) __attribute__ ((const));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF
	
		MkPrintN('checking for deprecated attribute...');
		TryCompileFlagsC('HAVE_DEPRECATED_ATTRIBUTE', '', << 'EOF');
void foo(void) __attribute__ ((deprecated));
void foo(void) { }

int main(int argc, char *argv[])
{
/*	foo(); */
	return (0);
}
EOF
	
		MkPrintN('checking for __format__ attribute...');
		MkCompileC('HAVE_FORMAT_ATTRIBUTE', '', '', << 'EOF');
#include <stdarg.h>
void foo1(char *, ...)
     __attribute__((__format__ (printf, 1, 2)));
void foo2(char *, ...)
     __attribute__((__format__ (__printf__, 1, 2)))
     __attribute__((__nonnull__ (1)));
void foo1(char *a, ...) {}
void foo2(char *a, ...) {}
int main(int argc, char *argv[])
{
	foo1("foo %s", "bar");
	foo2("foo %d", 1);
	return (0);
}
EOF

		MkPrintN('checking for __nonnull__ attribute...');
		TryCompileFlagsC('HAVE_NONNULL_ATTRIBUTE', '-Wall -Werror', << 'EOF');
void foo(char *) __attribute__((__nonnull__ (1)));
void foo(char *a) { }
int main(int argc, char *argv[])
{
	foo("foo");
	return (0);
}
EOF
	
		MkPrintN('checking for noreturn attribute...');
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

		MkPrintN('checking for packed attribute...');
		TryCompileFlagsC('HAVE_PACKED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { char c; int x,y,z; } __attribute__ ((packed));
	return (0);
}
EOF
	
		MkPrintN('checking for pure attribute...');
		TryCompileFlagsC('HAVE_PURE_ATTRIBUTE', '', << 'EOF');
int foo(int) __attribute__ ((pure));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF
	
		MkPrintN('checking for warn_unused_result attribute...');
		TryCompileFlagsC('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE', '', << 'EOF');
int foo(void) __attribute__ ((warn_unused_result));
int foo(void) { return (1); }
int main(int argc, char *argv[])
{
	int rv = foo();
	return (rv);
}
EOF
		
		MkPrintN('checking for unused variable attribute...');
		TryCompileFlagsC('HAVE_UNUSED_VARIABLE_ATTRIBUTE', '', << 'EOF');
int main(int argc, char *argv[])
{
	int __attribute__ ((unused)) variable;
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkSaveUndef('HAVE_ALIGNED_ATTRIBUTE');
	MkSaveUndef('HAVE_BOUNDED_ATTRIBUTE');
	MkSaveUndef('HAVE_CONST_ATTRIBUTE');
	MkSaveUndef('HAVE_DEPRECATED_ATTRIBUTE');
	MkSaveUndef('HAVE_FORMAT_ATTRIBUTE');
	MkSaveUndef('HAVE_NONNULL_ATTRIBUTE');
	MkSaveUndef('HAVE_NORETURN_ATTRIBUTE');
	MkSaveUndef('HAVE_PACKED_ATTRIBUTE');
	MkSaveUndef('HAVE_PURE_ATTRIBUTE');
	MkSaveUndef('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE');
	MkSaveUndef('HAVE_UNUSED_VARIABLE_ATTRIBUTE');
	return (1);
}

BEGIN
{
	$TESTS{'cc_attributes'} = \&Test;
	$EMUL{'cc_attributes'} = \&Emul;
	$DESCR{'cc_attributes'} = 'aligned attribute';
	$DEPS{'cc_attributes'} = 'cc';
}

;1
