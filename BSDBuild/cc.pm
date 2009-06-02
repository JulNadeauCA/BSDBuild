# $Csoft: cc.pm,v 1.21 2004/01/25 04:03:15 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003, 2004 CubeSoft Communications
# <http://www.csoft.org>
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
	# Look for a compiler.
	print << 'EOF';
if [ "$CC" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/cc" ]; then
			if [ -f "${i}/cc" ]; then
				CC="${i}/cc"
				break
			fi
		elif [ -x "${i}/gcc" ]; then
			if [ -f "${i}/gcc" ]; then
				CC="${i}/gcc"
				break
			fi
		fi
	done
	if [ "$CC" = "" ]; then
		echo "Unable to find a C compiler in PATH. Please set your compiler"
		echo "explicitely with the CC environment variable."
		echo "Unable to find a C compiler in PATH." >> config.log
		exit 1
	fi
fi

cat << 'EOT' > conftest.c
int main(int argc, char *argv[]) { return (0); }
EOT

$CC -o conftest conftest.c 2>>config.log
if [ $? != 0 ]; then
    echo "no"
	echo "Test C program (conftest.c) failed to compile."
	echo "Test C program (conftest.c) failed to compile." >> config.log
    exit 1
fi

EXECSUFFIX=""
for OUTFILE in conftest.exe conftest conftest.*; do
	if [ -f $OUTFILE ]; then
		case $OUTFILE in
		*.c | *.o | *.obj | *.bb | *.bbg | *.d | *.pdb | *.tds | *.xcoff | *.dSYM | *.xSYM )
			;;
		*.* )
			EXECSUFFIX=`expr "$OUTFILE" : '[^.]*\(\..*\)'`
			break ;;
		* )
			break ;;
		esac;
    fi
done
if [ "$EXECSUFFIX" != "" ]; then
	echo "Detected executable suffix: $EXECSUFFIX" >> config.log
fi
echo "EXECSUFFIX=$EXECSUFFIX" >> Makefile.config
echo "#ifndef EXECSUFFIX" > config/execsuffix.h
echo "#define EXECSUFFIX \"${EXECSUFFIX}\"" >> config/execsuffix.h
echo "#endif /* EXECSUFFIX */" >> config/execsuffix.h

echo "yes"
rm -f conftest.c conftest$EXECSUFFIX
TEST_CFLAGS=""
EOF

	MkPrintN('checking for compiler warning options...');
	MkCompileC('HAVE_CC_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
	MkIf('"${HAVE_CC_WARNINGS}" = "yes"');
		MkDefine('TEST_CFLAGS', '-Wall -Werror');
	MkEndif;
	
	MkPrintN('checking for gcc...');
	MkCompileC('HAVE_GCC', '', '', << 'EOF');
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF

	# Check for floating point support.
	# TODO representation
	MkPrintN('checking for IEEE754 floating point...');
	MkCompileC('HAVE_IEEE754', '', '', << 'EOF');
int
main(int argc, char *argv[])
{
	float f = 1.5;
	double d = 2.5;
	f = 0;
	d = 0;
	return (0);
}
EOF
	
	MkPrintN('checking aligned attribute...');
	TryCompileFlagsC('HAVE_ALIGNED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { int x,y,z; } __attribute__ ((aligned(16)));
	return (0);
}
EOF

	MkPrintN('checking bounded attribute...');
	MkCompileC('HAVE_BOUNDED_ATTRIBUTE', '', '', << 'EOF');
void foo(char *, int) __attribute__ ((__bounded__(__string__,1,2)));
void foo(char *a, int c) { }
int main(int argc, char *argv[])
{
	char buf[32];
	foo(buf, sizeof(buf));
	return (0);
}
EOF
	
	MkPrintN('checking const attribute...');
	TryCompileFlagsC('HAVE_CONST_ATTRIBUTE', '', << 'EOF');
int foo(int) __attribute__ ((const));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF
	
	MkPrintN('checking deprecated attribute...');
	TryCompileFlagsC('HAVE_DEPRECATED_ATTRIBUTE', '', << 'EOF');
void foo(void) __attribute__ ((deprecated));
void foo(void) { }

int main(int argc, char *argv[])
{
/*	foo(); */
	return (0);
}
EOF
	
	MkPrintN('checking format attribute...');
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

	MkPrintN('checking nonnull attribute...');
	TryCompileFlagsC('HAVE_NONNULL_ATTRIBUTE', '-Wall -Werror', << 'EOF');
void foo(char *) __attribute__((__nonnull__ (1)));
void foo(char *a) { }
int main(int argc, char *argv[])
{
	foo("foo");
	return (0);
}
EOF
	
	MkPrintN('checking noreturn attribute...');
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

	MkPrintN('checking packed attribute...');
	TryCompileFlagsC('HAVE_PACKED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { char c; int x,y,z; } __attribute__ ((packed));
	return (0);
}
EOF
	
	MkPrintN('checking pure attribute...');
	TryCompileFlagsC('HAVE_PURE_ATTRIBUTE', '', << 'EOF');
int foo(int) __attribute__ ((pure));
int foo(int x) { return (x*x); }
int main(int argc, char *argv[])
{
	int x = foo(1);
	return (x);
}
EOF
	
	MkPrintN('checking warn_unused_result attribute...');
	TryCompileFlagsC('HAVE_WARN_UNUSED_RESULT_ATTRIBUTE', '', << 'EOF');
int foo(void) __attribute__ ((warn_unused_result));
int foo(void) { return (1); }
int main(int argc, char *argv[])
{
	int rv = foo();
	return (rv);
}
EOF
	
	# Check for long double type.
	MkPrintN('checking for long double...');
	TryCompile('HAVE_LONG_DOUBLE', << 'EOF');
int
main(int argc, char *argv[])
{
	long double ld = 0.1;

	ld = 0;
	return (0);
}
EOF
	
	# Check for long long type.
	MkPrintN('checking for long long...');
	TryCompile('HAVE_LONG_LONG', << 'EOF');
int
main(int argc, char *argv[])
{
	long long ll = 0.0;
	unsigned long long ull = 0.0;
	ll = 1.0;
	ull = 1.0;
	return (0);
}
EOF

	MkPrintN('checking for cygwin environment...');
	TryCompileFlagsC('HAVE_CYGWIN', '-mcygwin', << 'EOF');
#include <sys/types.h>
#include <sys/stat.h>
#include <windows.h>

int
main(int argc, char *argv[]) {
	struct stat sb;
	DWORD rv;
	rv = GetFileAttributes("foo");
	stat("foo", &sb);
	return (0);
}
EOF
	print << 'EOF';
if [ "${MK_COMPILE_STATUS}" = "OK" ]; then
	if [ "${with_cygwin}" != "yes" ]; then
		echo "* Disabling cygwin compatibility layer"
		CFLAGS="$CFLAGS -mno-cygwin"
		echo "CFLAGS=$CFLAGS" >> Makefile.config
	else
		echo "* Using cygwin compatibility layer"
	fi
fi
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkDefine('HAVE_IEEE754', 'yes');
	MkSaveDefine('HAVE_IEEE754');

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

	MkSaveUndef('HAVE_LONG_DOUBLE');
	MkSaveUndef('HAVE_LONG_LONG');
	
	MkSaveUndef('HAVE_CYGWIN');
	return (1);
}

BEGIN
{
	$TESTS{'cc'} = \&Test;
	$EMUL{'cc'} = \&Emul;
	$DESCR{'cc'} = 'a usable C compiler';
}

;1
