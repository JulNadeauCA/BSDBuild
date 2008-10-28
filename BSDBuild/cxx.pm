# vim:ts=4
#
# Copyright (c) 2007 CubeSoft Communications, Inc.
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
	print << 'EOF';
if [ "$CXX" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/c++" ]; then
			if [ -f "${i}/c++" ]; then
				CXX="${i}/c++"
				break
			fi
		elif [ -x "${i}/gcc" ]; then
			if [ -f "${i}/gcc" ]; then
				CXX="${i}/gcc"
				break
			fi
		fi
	done
	if [ "$CXX" = "" ]; then
		echo "Could not find a C++ compiler, try setting CXX."
		echo "CXX is unset and c++/gcc is not in PATH." >> config.log
		exit 1
	fi
fi

cat << 'EOT' > cxx-test.c
int
main(int argc, char *argv[])
{
	return (0);
}
EOT

$CXX -o cxx-test cxx-test.c 2>>config.log
if [ $? != 0 ]; then
    echo "no"
	echo "The test C++ program failed to compile."
	rm -f cxx-test cxx-test.c
    exit 1
fi
echo "yes"
rm -f cxx-test cxx-test.c
TEST_CXXFLAGS=""
EOF
	
	MkPrintN('checking for c++ compiler warnings...');
	MkCompileCXX('CXX_HAVE_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
	MkIf('"${CXX_HAVE_WARNINGS}" = "yes"');
		MkDefine('TEST_CXXFLAGS', '-Wall -Werror');
	MkEndif;

	MkPrintN('checking for __bounded__ attribute in c++...');
	MkCompileCXX('CXX_HAVE_BOUNDED_ATTRIBUTE', '', '', << 'EOF');
void foo(char *, int) __attribute__ ((__bounded__(__string__,1,2)));
void foo(char *a, int c) { }
int main(int argc, char *argv[])
{
	char buf[32];
	foo(buf, sizeof(buf));
	return (0);
}
EOF
	
	MkPrintN('checking for __format__ attribute in c++...');
	MkCompileCXX('CXX_HAVE_FORMAT_ATTRIBUTE', '', '', << 'EOF');
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

	MkPrintN('checking for __nonnull__ attribute in c++...');
	TryCompileFlagsCXX('CXX_HAVE_NONNULL_ATTRIBUTE', '-Wall -Werror', << 'EOF');
void foo(char *) __attribute__((__nonnull__ (1)));
void foo(char *a) { }
int main(int argc, char *argv[])
{
	foo("foo");
	return (0);
}
EOF

	MkPrintN('checking for __aligned__ attribute in c++...');
	TryCompileFlagsCXX('CXX_HAVE_ALIGNED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { int x,y,z; } __attribute__ ((aligned(16)));
	return (0);
}
EOF
	
	MkPrintN('checking for __packed__ attribute in c++...');
	TryCompileFlagsCXX('CXX_HAVE_PACKED_ATTRIBUTE', '-Wall -Werror', << 'EOF');
int main(int argc, char *argv[])
{
	struct s1 { char c; int x,y,z; } __attribute__ ((packed));
	return (0);
}
EOF
	
	MkPrintN('checking for cygwin environment in c++...');
	TryCompileFlagsCXX('CXX_HAVE_CYGWIN', '-mcygwin', << 'EOF');
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
		CXXFLAGS="$CXXFLAGS -mno-cygwin"
		echo "CXXFLAGS=$CXXFLAGS" >> Makefile.config
	fi
fi
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkSaveUndef('CXX_HAVE_BOUNDED_ATTRIBUTE');
	MkSaveUndef('CXX_HAVE_FORMAT_ATTRIBUTE');
	MkSaveUndef('CXX_HAVE_NONNULL_ATTRIBUTE');
	MkSaveUndef('CXX_HAVE_ALIGNED_ATTRIBUTE');
	MkSaveUndef('CXX_HAVE_PACKED_ATTRIBUTE');

	MkSaveUndef('CXX_HAVE_CYGWIN');
	return (1);
}

BEGIN
{
	$TESTS{'cxx'} = \&Test;
	$EMUL{'cxx'} = \&Emul;
	$DESCR{'cxx'} = 'a usable C++ compiler';
}

;1
