# Public domain
# vim:ts=4

sub TEST_cc
{
	my @cc_try = ('clang', 'clang70', 'clang60', 'cc',
                  'gcc', 'gcc-6', 'gcc7', 'gcc8', 'gcc5', 'gcc49', 'gcc48',
                  'clang.exe', 'cc.exe', 'gcc.exe');
	my $cc65_tgts = 'apple2 | apple2enh | atari | atmos | c16 | '.
                    'c64 | c128 | cbm510 | cbm610 | geos | lunix | '.
                    'lynx | nes | pet | plus4 | supervision | vic20';

	MkIfTrue('$CROSS_COMPILING');
		MkDefine('CROSSPFX', '${host}-');
	MkElse;
		MkDefine('CROSSPFX', '');
	MkEndif;

	MkDefine('HAVE_CC65', 'no');
	MkIfEQ('$CC', '');										# Unspecified CC
		MkCaseIn('${host}');
			MkCaseBegin($cc65_tgts);						# cc65-only targets
				MkPushIFS('$PATH_SEPARATOR');
				MkFor('i', '$PATH');
					MkIf('-x "${i}/cc65"');
						MkIfExec('${i}/cc65 -V |grep ^cc65');
							MkDefine('CC', '${i}/cc65');
							MkDefine('HAVE_CC65', 'yes');
							MkDefine('CROSS_COMPILING', 'yes');
							MkBreak;
						MkEndif;
					MkElif('-x "${i}/cc65.exe"');
						MkIfExec('${i}/cc65.exe -V |grep ^cc65');
							MkDefine('CC', '${i}/cc65.exe');
							MkDefine('HAVE_CC65', 'yes');
							MkDefine('CROSS_COMPILING', 'yes');
							MkBreak;
						MkEndif;
					MkEndif;
				MkDone;
				MkPopIFS();
			MkCaseEnd();
			MkCaseBegin('*');								# any other target
				MkPushIFS('$PATH_SEPARATOR');
				MkFor('i', '$PATH');
	my @try = @cc_try;
	my $cc = shift(@try);
					MkIf('-x "${i}/${CROSSPFX}'.$cc.'"');
					MkDefine('CC', '${i}/${CROSSPFX}'.$cc);
					MkBreak;
	foreach $cc (@try) {
					MkElif('-x "${i}/${CROSSPFX}'.$cc.'"');
					MkDefine('CC', '${i}/${CROSSPFX}'.$cc);
					MkBreak;
	}
				MkEndif;
				MkDone;
				MkPopIFS();
			MkCaseEnd();
		MkEsac();

	print << 'EOF';
	if [ "$CC" = '' ]; then
		if [ "$HAVE_CC65" = "yes" ]; then
			echo "*"
			echo "* Cannot find cc65 in PATH. You may need to set CC."
			echo "* You can download cc65 from: https://www.cc65.org/."
			echo "*"
			echo "Cannot find cc65 in PATH." >> config.log
		else
			echo "*"
EOF
	print 'echo "* Cannot find one of ' . join(', ',@cc_try) . '"', "\n";
	print << 'EOF';
			echo "* under the current PATH, which is:"
			echo "* $PATH"
			echo "*"
			echo "* You may need to set the CC environment variable."
			echo "*"
			echo "Cannot find C compiler in PATH." >> config.log
		fi
		HAVE_CC="no"
		echo "no"
	else
		HAVE_CC="yes"
		echo "yes, ${CC}"
		echo "yes, ${CC}" >> config.log
	fi
else
	HAVE_CC="yes"
	if ${CC} -V 2>&1 |grep -q ^cc65; then
		echo "using cc65 (${CC})"
		HAVE_CC65="yes"
		CROSS_COMPILING="yes"
	else
		echo "using ${CC}"
	fi
fi

if [ "${HAVE_CC}" = "yes" ]; then
	$ECHO_N 'checking whether the C compiler works...'
	$ECHO_N 'checking whether the C compiler works...' >> config.log
	cat << 'EOT' > conftest.c
int main(int argc, char *argv[]) { return (0); }
EOT
	$CC -o conftest conftest.c 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compile failed" >> config.log
		HAVE_CC="no"
	else
		HAVE_CC="yes"
	fi

	if [ "${HAVE_CC}" = "yes" ]; then
		if [ "${EXECSUFFIX}" = '' ]; then
			EXECSUFFIX=''
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
			if [ "$EXECSUFFIX" != '' ]; then
				echo "yes, it outputs $EXECSUFFIX files"
				echo "yes, it outputs $EXECSUFFIX files" >> config.log
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
	if [ "${keep_conftest}" != "yes" ]; then
		rm -f conftest.c conftest$EXECSUFFIX
	fi
	TEST_CFLAGS=''
fi
EOF
	
	MkIfTrue('${HAVE_CC}');

		MkPrintSN('cc: checking for compiler warning options...');
		MkCompileC('HAVE_CC_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
		MkIfTrue('${HAVE_CC_WARNINGS}');
			MkDefine('TEST_CFLAGS', '-Wall -Werror');
		MkEndif;
		
		# Check for float type.
		MkPrintSN('cc: checking for float and double...');
		TryCompile('HAVE_FLOAT', << 'EOF');
#include <stdio.h>
int
main(int argc, char *argv[])
{
	float f = 0.1f;
	double d = 0.2;

	printf("%f", f);
	return ((double)f + d) > 0.2 ? 1 : 0;
}
EOF
	
		# Check for long double type.
		# XXX: should rename to HAVE_CC_LONG_DOUBLE
		MkPrintSN('cc: checking for long double...');
		TryCompile('HAVE_LONG_DOUBLE', << 'EOF');
#include <stdio.h>
int
main(int argc, char *argv[])
{
	long double ld = 0.1;

	printf("%Lf", ld);
	return (ld + 0.1) > 0.2 ? 1 : 0;
}
EOF
	
		# Check for long long type.
		# XXX: should rename to HAVE_CC_LONG_LONG
		MkPrintSN('cc: checking for long long...');
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
		MkPrintSN('cc: checking for cygwin environment...');
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
		MkPrintSN('cc: checking for -mwindows option...');
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
		
		MkPrintSN('cc: checking for -mconsole option...');
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
			MkPrintSN('cc: checking for linker -no-undefined option...');
			TryCompileFlagsC('HAVE_LD_NO_UNDEFINED',
			    '-Wl,--no-undefined', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
			MkIfTrue('${HAVE_LD_NO_UNDEFINED}');
				MkDefine('LIBTOOLOPTS_SHARED',
				    '${LIBTOOLOPTS_SHARED} -no-undefined -Wl,--no-undefined');
			MkEndif;
			MkPrintSN('cc: checking for linker -static-libgcc option...');
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
		
		MkSaveDefine('HAVE_CC');
		
		MkIfTrue('${HAVE_CC65}');
			MkDefine('CC_COMPILE', '');
			MkSaveDefine('HAVE_CC65');
		MkElse;
			MkDefine('CC_COMPILE', '-c');
			MkSaveUndef('HAVE_CC65');
		MkEndif;

		MkSaveMK('HAVE_CC', 'HAVE_CC65', 'CC', 'CC_COMPILE', 'CFLAGS',
                 'PROG_GUI_FLAGS', 'PROG_CLI_FLAGS', 'LIBTOOLOPTS_SHARED');

	MkElse;
		DISABLE_cc();
	MkEndif;
}

sub DISABLE_cc
{
	MkDefine('HAVE_CC', 'no');
	MkDefine('HAVE_CC65', 'no');
	MkDefine('HAVE_CC_WARNINGS', 'no');
	MkDefine('PROG_GUI_FLAGS', '');
	MkDefine('PROG_CLI_FLAGS', '');
	MkDefine('LIBTOOLOPTS_SHARED', '');
	MkDefine('TEST_CFLAGS', '');

	MkSaveUndef('HAVE_CC', 'HAVE_CC65', 'HAVE_CC_WARNINGS',
	            'HAVE_FLOAT', 'HAVE_LONG_DOUBLE', 'HAVE_LONG_LONG',
	            'HAVE_CYGWIN', 'HAVE_CC_MWINDOWS', 'HAVE_CC_MCONSOLE',
	            'HAVE_LD_NO_UNDEFINED', 'HAVE_LD_STATIC_LIBGCC');

	MkSaveMK('HAVE_CC', 'HAVE_CC65', 'HAVE_CC_WARNINGS', 'CC', 'CFLAGS',
             'PROG_GUI_CFLAGS', 'PROG_CLI_CFLAGS', 'LIBTOOLOPTS_SHARED');
}

BEGIN
{
	$DESCR{'cc'}   = 'a C compiler';
	$TESTS{'cc'}   = \&TEST_cc;
	$DISABLE{'cc'} = \&DISABLE_cc;

	RegisterEnvVar('CC',		'C compiler command');
	RegisterEnvVar('CFLAGS',	'C compiler flags');
	RegisterEnvVar('LDFLAGS',	'C linker flags');
	RegisterEnvVar('LIBS',		'Libraries to link against');
	RegisterEnvVar('CPP',		'C preprocessor');
	RegisterEnvVar('CPPFLAGS',	'C preprocessor flags');
}
;1
