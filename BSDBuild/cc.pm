# vim:ts=4
#
# Copyright (c) 2002-2014 Hypertriton, Inc. <http://hypertriton.com/>
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
if [ "$CROSS_COMPILING" = "yes" ]; then
	CROSSPFX="${host}-"
else
	CROSSPFX=""
fi
if [ "$CC" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/${CROSSPFX}cc" ]; then
			if [ -f "${i}/${CROSSPFX}cc" ]; then
				CC="${i}/${CROSSPFX}cc"
				break
			fi
		elif [ -x "${i}/${CROSSPFX}gcc" ]; then
			if [ -f "${i}/${CROSSPFX}gcc" ]; then
				CC="${i}/${CROSSPFX}gcc"
				break
			fi
		fi
	done
	if [ "$CC" = "" ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}cc or ${CROSSPFX}gcc in default PATH."
		echo "* You may need to set the CC environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}cc or ${CROSSPFX}gcc in PATH." >> config.log
		HAVE_CC="no"
		echo "no"
	else
		HAVE_CC="yes"
		echo "yes, ${CC}"
		echo "yes, ${CC}" >> config.log
	fi
else
	HAVE_CC="yes"
	echo "using ${CC}"
fi

if [ "${HAVE_CC}" = "yes" ]; then
	$ECHO_N "checking whether the C compiler works..."
	$ECHO_N "checking whether the C compiler works..." >> config.log
	cat << 'EOT' > conftest.c
int main(int argc, char *argv[]) { return (0); }
EOT
	$CC -o conftest conftest.c 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no (test failed to compile)" >> config.log
		HAVE_CC="no"
	else
		HAVE_CC="yes"
	fi

	if [ "${HAVE_CC}" = "yes" ]; then
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
				echo "yes (it outputs $EXECSUFFIX files)"
				echo "yes (it outputs $EXECSUFFIX files)" >> config.log
			else
				echo "yes"
				echo "yes" >> config.log
			fi
EOF
	MkSaveMK('EXECSUFFIX');
	MkSaveDefine('EXECSUFFIX');
	print << 'EOF';
		else
			echo "yes"
			echo "yes" >> config.log
		fi
	fi
	rm -f conftest.c conftest$EXECSUFFIX
	TEST_CFLAGS=""
fi
EOF
	
	MkIfTrue('${HAVE_CC}');

		MkPrintN('cc: checking for compiler warning options...');
		MkCompileC('HAVE_CC_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
		MkIfTrue('${HAVE_CC_WARNINGS}');
			MkDefine('TEST_CFLAGS', '-Wall -Werror');
		MkEndif;
	
		# Check for long double type.
		# XXX: should rename to HAVE_CC_LONG_DOUBLE
		MkPrintN('cc: checking for long double...');
		TryCompile('HAVE_LONG_DOUBLE', << 'EOF');
#include <stdio.h>
int
main(int argc, char *argv[])
{
	long double ld = 0.1;

	printf("%Lf", ld);
	return (ld == 1.0);
}
EOF
	
		# Check for long long type.
		# XXX: should rename to HAVE_CC_LONG_LONG
		MkPrintN('cc: checking for long long...');
		TryCompile('HAVE_LONG_LONG', << 'EOF');
int
main(int argc, char *argv[])
{
	long long ll = -1;
	unsigned long long ull = 1;

	return (ll != -1 || ull != 1);
}
EOF

		# XXX: should rename to HAVE_CC_CYGWIN
		MkPrintN('cc: checking for cygwin environment...');
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
		MkPrintN('cc: checking for -mwindows option...');
		TryCompileFlagsC('HAVE_CC_MWINDOWS', '-mwindows', << 'EOF');
#include <windows.h>
int
main(int argc, char *argv[]) {
	return GetFileAttributes("foo") ? 0 : 1;
}
EOF
		MkIfTrue('${HAVE_CC_MWINDOWS}');
			MkDefine('PROG_GUI_FLAGS', '-mwindows');
		MkElse;
			MkDefine('PROG_GUI_FLAGS', '');
		MkEndif;
		
		MkPrintN('cc: checking for -mconsole option...');
		TryCompileFlagsC('HAVE_CC_MCONSOLE', '-mconsole', << 'EOF');
#include <windows.h>
int
main(int argc, char *argv[]) {
	return GetFileAttributes("foo") ? 0 : 1;
}
EOF
		MkIfTrue('${HAVE_CC_MCONSOLE}');
			MkDefine('PROG_CLI_FLAGS', '-mconsole');
		MkElse;
			MkDefine('PROG_CLI_FLAGS', '');
		MkEndif;
		
		MkCaseIn('${host}');
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkPrintN('cc: checking for linker -no-undefined option...');
			TryCompileFlagsC('HAVE_LD_NO_UNDEFINED',
			    '-Wl,--no-undefined', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
			MkIfTrue('${HAVE_LD_NO_UNDEFINED}');
				MkDefine('LIBTOOLOPTS_SHARED',
				    '${LIBTOOLOPTS_SHARED} -no-undefined -Wl,--no-undefined');
			MkEndif;
			MkPrintN('cc: checking for linker -static-libgcc option...');
			TryCompileFlagsC('HAVE_LD_STATIC_LIBGCC',
			    '-static-libgcc', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
			MkIfTrue('${HAVE_LD_STATIC_LIBGCC}');
				MkDefine('LIBTOOLOPTS_SHARED',
				    '${LIBTOOLOPTS_SHARED} -XCClinker -static-libgcc');
			MkEndif;
			MkCaseEnd;
		MkEsac;

		MkSaveMK('CC', 'CFLAGS', 'PROG_GUI_FLAGS', 'PROG_CLI_FLAGS',
		         'LIBTOOLOPTS_SHARED');

	MkEndif; # HAVE_CC
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
	MkSaveUndef('HAVE_LONG_DOUBLE');
	MkSaveUndef('HAVE_LONG_LONG');
	MkSaveUndef('HAVE_CYGWIN');
	return (1);
}

BEGIN
{
	$TESTS{'cc'} = \&Test;
	$EMUL{'cc'} = \&Emul;
	$DESCR{'cc'} = 'a C compiler';
}

;1
