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
	# Look for a C++ compiler.
	# XXX duplicated code between cc/cxx

	print << 'EOF';
if [ "$CXX" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/cxx" ]; then
			if [ -f "${i}/cxx" ]; then
				CXX="${i}/cxx"
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
		echo "*"
		echo "* Unable to find a standard C++ compiler in PATH. You may need"
		echo "* to set the CXX environment variable."
		echo "*"
		echo "Unable to find a C compiler in PATH." >> config.log
		HAVE_CXX="no"
		echo "no"
	else
		HAVE_CXX="yes"
		echo "yes, ${CXX}"
		echo "yes, ${CXX}" >> config.log
	fi
else
	echo "using ${CXX}"
fi

if [ "${HAVE_CXX}" = "yes" ]; then
	$ECHO_N "checking whether the C++ compiler works..."
	$ECHO_N "checking whether the C++ compiler works..." >> config.log
	cat << 'EOT' > conftest.cc
#include <iostream>
int main(void) { std::cout << "Hello world!" << std::endl; return 0; }
EOT
	$CXX -o conftest conftest.cc -lstdc++ 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no (test failed to compile)" >> config.log
		HAVE_CXX="no"
	else
		echo "yes"
		echo "yes" >> config.log
		HAVE_CXX="yes"
	fi

	if [ "${HAVE_CXX}" = "yes" ]; then
		if [ "${EXECSUFFIX}" = "" ]; then
			EXECSUFFIX=""
			for OUTFILE in conftest.exe conftest conftest.*; do
				if [ -f $OUTFILE ]; then
					case $OUTFILE in
					*.c | *.cc | *.m | *.o | *.obj | *.bb | *.bbg | *.d | *.pdb | *.tds | *.xcoff | *.dSYM | *.xSYM )
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
EOF
	MkSaveMK('EXECSUFFIX');
	MkSaveDefine('EXECSUFFIX');

print << 'EOF';
		fi
	fi
	rm -f conftest.cc conftest$EXECSUFFIX
	TEST_CXXFLAGS=""
fi
EOF

	MkIfTrue('${HAVE_CXX}');

		MkPrintN('checking for c++ compiler warning options...');
		MkCompileCXX('HAVE_CXX_WARNINGS', '-Wall -Werror', '-lstdc++', << 'EOF');
int main(void) { return (0); }
EOF
		MkIfTrue('${HAVE_CXX_WARNINGS}');
			MkDefine('TEST_CXXFLAGS', '-Wall -Werror');
		MkEndif;
	
		# Check for long double type.
		MkPrintN('checking for long double...');
		TryCompile('HAVE_LONG_DOUBLE', << 'EOF');
int
main(void)
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
main(void)
{
	long long ll = 0.0;
	unsigned long long ull = 0.0;
	ll = 1.0;
	ull = 1.0;
	return (0);
}
EOF

		MkPrintN('checking for cygwin environment...');
		TryCompileFlagsCXX('HAVE_CYGWIN', '-mcygwin', << 'EOF');
#include <sys/types.h>
#include <sys/stat.h>
#include <windows.h>

int
main(void) {
	struct stat sb;
	DWORD rv;
	rv = GetFileAttributes("foo");
	stat("foo", &sb);
	return (0);
}
EOF

		MkPrintN('checking for libtool --tag=CXX retardation...');
		print 'cat << EOT > conftest.cc', "\n";
		print << 'EOF';
#include <iostream>
int main(void) { std::cout << "Hello world!" << std::endl; return 0; }
EOT
EOF
	print << "EOF";
\$LIBTOOL --quiet --mode=compile --tag=CXX \$CXX \$CXXFLAGS \$TEST_CXXFLAGS -o \$testdir/conftest.o conftest.cc 2>>config.log
EOF
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkDefine('LIBTOOLOPTS_CXX', '--tag=CXX');
		MkElse;
			MkPrint('no');
		MkEndif;
		MkSaveMK('LIBTOOLOPTS_CXX');
		print 'rm -f conftest.cc $testdir/conftest$EXECSUFFIX', "\n";

		# Preserve ${CXX} and ${CXXFLAGS}
		MkSaveMK('CXX', 'CXXFLAGS');

	MkEndif; # HAVE_CXX
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkDefine('HAVE_IEEE754', 'yes');
	MkSaveDefine('HAVE_IEEE754');

	MkSaveUndef('HAVE_LONG_DOUBLE');
	MkSaveUndef('HAVE_LONG_LONG');
	MkSaveUndef('HAVE_CYGWIN');
	return (1);
}

BEGIN
{
	$TESTS{'cxx'} = \&Test;
	$EMUL{'cxx'} = \&Emul;
	$DESCR{'cxx'} = 'a C++ compiler';
}

;1
