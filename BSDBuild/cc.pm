# Public domain

sub TEST_cc
{
	# Compilers to try and detect
	my @cc_try = ('clang', 'clang70', 'clang60', 'cc',
	              'gcc', 'gcc-6', 'gcc7', 'gcc8', 'gcc5', 'gcc49', 'gcc48',
	              'clang.exe', 'cc.exe', 'gcc.exe');

	# Emscripten-only targets (WebAssembly / wasm).
	my $emcc_tgts = 'emscripten';

	# 65(C)02 targets (8-bit systems).
	my $cc65_tgts = 'apple2 | apple2enh | atari | atmos | c16 | '.
	                'c64 | c128 | cbm510 | cbm610 | geos | lunix | '.
	                'lynx | nes | pet | plus4 | supervision | vic20';

	my $mainTest = << 'EOF';
int main(int argc, char *argv[]) { return(0); }';
EOF
	my $winTest = << 'EOF';
#include <windows.h>
int
main(int argc, char *argv[]) {
	return GetFileAttributes("foo") ? 0 : 1;
}
EOF

	MkIfTrue('$CROSS_COMPILING');
		MkDefine('CROSSPFX', '${host}-');
	MkElse;
		MkDefine('CROSSPFX', '');
	MkEndif;

	MkDefine('HAVE_CC65', 'no');
	MkDefine('HAVE_EMCC', 'no');

	MkIfEQ('$CC', '');				# Unspecified CC
		MkCaseIn('${host}');
			MkCaseBegin($emcc_tgts);	# emscripten-only targets
				MkPushIFS('$PATH_SEPARATOR');
				MkFor('i', '$PATH');
					MkIf('-x "${i}/emcc"');
						MkDefine('CC', '${i}/emcc');
						MkDefine('HAVE_EMCC', 'yes');
						MkDefine('CROSS_COMPILING', 'yes');
						MkBreak;
					MkElif('-x "${i}/emcc.exe"');
						MkDefine('CC', '${i}/emcc.exe');
						MkDefine('HAVE_EMCC', 'yes');
						MkDefine('CROSS_COMPILING', 'yes');
						MkBreak;
					MkEndif;
				MkDone;
				MkPopIFS();
			MkCaseEnd();
			MkCaseBegin($cc65_tgts);	# cc65-only targets
				MkPushIFS('$PATH_SEPARATOR');
				MkFor('i', '$PATH');
					MkIf('-x "${i}/cc65"');
						MkDefine('CC', '${i}/cc65');
						MkDefine('HAVE_CC65', 'yes');
						MkDefine('CROSS_COMPILING', 'yes');
						MkBreak;
					MkElif('-x "${i}/cc65.exe"');
						MkDefine('CC', '${i}/cc65.exe');
						MkDefine('HAVE_CC65', 'yes');
						MkDefine('CROSS_COMPILING', 'yes');
						MkBreak;
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
		echo "*"
EOF
	print  'echo "* Cannot find one of ' . join(', ',@cc_try) . '"', "\n";
	print << 'EOF';
		echo "* under the current PATH, which is:"
		echo "* $PATH"
		echo "*"
		echo "* You may need to set the CC environment variable."
		echo "*"
		echo "Cannot find C compiler in PATH." >>config.log
		echo "no"
		echo "no" >>config.log

		HAVE_CC="no"
	else
		echo "yes, ${CC}"
		echo "yes, ${CC}" >>config.log

		HAVE_CC="yes"
	fi
else
	HAVE_CC="yes"
	if emcc --version 2>&1 |grep -q ^emcc; then
		echo "using emcc (${CC})"
		echo "using emcc (${CC})" >>config.log
		HAVE_EMCC="yes"
		CROSS_COMPILING="yes"
	elif cc65 -V 2>&1 |grep -q ^cc65; then
		echo "using cc65 (${CC})"
		echo "using cc65 (${CC})" >>config.log
		HAVE_CC65="yes"
		CROSS_COMPILING="yes"
	else
		echo "using ${CC}"
		echo "using ${CC}" >>config.log
	fi
fi

if [ "${HAVE_CC}" = "yes" ]; then
	$ECHO_N 'checking whether the C compiler works...'
	$ECHO_N '# checking whether the C compiler works...' >>config.log
	cat << 'EOT' > conftest.c
int main(int argc, char *argv[]) { return (0); }
EOT
	$CC -o conftest conftest.c 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compilation failed" >>config.log
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
					*.c | *.cc | *.m | *.o | *.obj | *.bb | *.bbg | *.d | *.pdb | *.tds | *.xcoff | *.dSYM | *.xSYM | *.wasm )
						;;
					*.* )
						EXECSUFFIX=`expr "$OUTFILE" : '[^.]*\(\..*\)'`
						break ;;
					* )
						break ;;
					esac;
			    fi
			done
			if [ "${HAVE_EMCC}" = "yes" ]; then
				EXECSUFFIX=".wasm"
			fi
			if [ "$EXECSUFFIX" != '' ]; then
				echo "yes, it outputs $EXECSUFFIX files"
				echo "yes, it outputs $EXECSUFFIX files" >>config.log
			else
				echo "yes"
				echo "yes" >>config.log
			fi
EOF
	
	MkSaveDefine('HAVE_EMCC');
	MkSaveDefine('HAVE_CC65');
	MkSaveDefine('EXECSUFFIX');

	print << 'EOF';
		else
			echo "yes"
			echo "yes" >>config.log
		fi
	fi
	if [ "${keep_conftest}" != "yes" ]; then
		rm -f conftest.c conftest conftest$EXECSUFFIX
	fi
	TEST_CFLAGS=''
fi
EOF
	
	MkIfTrue('${HAVE_CC}');

		MkPrintSN('cc: checking whether compiler is Clang...');
		MkCompileC('HAVE_CC_CLANG', '', '', << 'EOF');
#if !defined(__clang__)
# error "is not clang"
#endif
int main(int argc, char *argv[]) { return (0); }
EOF

		MkPrintSN('cc: checking whether compiler is GCC...');
		MkCompileC('HAVE_CC_GCC', '', '', << 'EOF');
#if !defined(__GNUC__) || defined(__clang__)
# error "is not gcc"
#endif
int main(int argc, char *argv[]) { return (0); }
EOF

		MkPrintSN('cc: checking for compiler warning options...');
		MkCompileC('HAVE_CC_WARNINGS', '-Wall', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
		MkIfTrue('${HAVE_CC_WARNINGS}');
			MkDefine('TEST_CFLAGS', '-Wall');
		MkEndif;
		
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
		
		MkCaseIn('${host}');
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkDefine('PICFLAGS', '');

			MkPrintSN('cc: checking for linker -no-undefined option...');
			TryCompileFlagsC('HAVE_LD_NO_UNDEFINED',
			                 '-Wl,--no-undefined', $mainTest);
			MkIfTrue('${HAVE_LD_NO_UNDEFINED}');
				MkDefine('LIBTOOLOPTS_SHARED',
				         '${LIBTOOLOPTS_SHARED} ' .
				         '-no-undefined -Wl,--no-undefined');
			MkEndif;

			MkPrintSN('cc: checking for linker -static-libgcc option...');
			TryCompileFlagsC('HAVE_LD_STATIC_LIBGCC', '-static-libgcc', $mainTest);
			MkIfTrue('${HAVE_LD_STATIC_LIBGCC}');
				MkDefine('LIBTOOLOPTS_SHARED',
				         '${LIBTOOLOPTS_SHARED} ' .
				         '-XCClinker -static-libgcc');
			MkEndif;

			MkPrintSN('cc: checking for cygwin environment...');
			TryCompileFlagsC('HAVE_CYGWIN', '-mcygwin', << 'EOF');
#include <sys/types.h>
#include <sys/stat.h>
#include <windows.h>
int main(int argc, char *argv[]) {
	struct stat sb;
	DWORD rv;
	rv = GetFileAttributes("foo");
	stat("foo", &sb);
	return(0);
}
EOF
			MkCaseEnd;

		MkCaseBegin('*');
			MkDefine('PICFLAGS', '-fPIC');

			MkDefine('HAVE_CYGWIN', 'no');
			MkSaveUndef('HAVE_CYGWIN');
			MkDefine('PROG_GUI_FLAGS', '');
			MkDefine('PROG_CLI_FLAGS', '');
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

		MkIfTrue('${HAVE_EMCC}');
			MkSaveDefine('HAVE_EMCC');
		MkElse;
			MkSaveUndef('HAVE_EMCC');
		MkEndif;
	MkElse;
		MkDisableFailed('cc');
	MkEndif;

}

sub DISABLE_cc
{
	MkDefine('HAVE_CC', 'no') unless $TestFailed;
	MkDefine('HAVE_CC65', 'no');
	MkDefine('HAVE_EMCC', 'no');
	MkDefine('HAVE_CC_WARNINGS', 'no');
	MkDefine('PROG_GUI_FLAGS', '');
	MkDefine('PROG_CLI_FLAGS', '');
	MkDefine('TEST_CFLAGS', '');

	MkSaveUndef('HAVE_CC', 'HAVE_CC_WARNINGS',
	            'HAVE_CC_CLANG', 'HAVE_CC_GCC', 'HAVE_CC65', 'HAVE_EMCC',
	            'HAVE_FLOAT', 'HAVE_LONG_DOUBLE', 'HAVE_LONG_LONG',
	            'HAVE_CYGWIN',
	            'HAVE_LD_NO_UNDEFINED', 'HAVE_LD_STATIC_LIBGCC');
}

sub EMUL_cc
{
	MkDefine('PROG_GUI_FLAGS', '');
	MkDefine('PROG_CLI_FLAGS', '');
	MkDefine('TEST_CFLAGS', '');

	MkDefine('HAVE_CC', 'yes');
	MkDefine('HAVE_FLOAT', 'yes');

	MkDefine('HAVE_CC65', 'no');
	MkDefine('HAVE_EMCC', 'no');
	MkDefine('HAVE_CC_WARNINGS', 'no');
	MkDefine('HAVE_LONG_DOUBLE', 'no');
	MkDefine('HAVE_LONG_LONG', 'no');
	MkDefine('HAVE_CYGWIN', 'no');
	MkDefine('HAVE_LD_NO_UNDEFINED', 'no');
	MkDefine('HAVE_LD_STATIC_LIBGCC', 'no');

	MkSaveDefine('HAVE_CC', 'HAVE_FLOAT');

	MkSaveUndef('HAVE_CC65', 'HAVE_EMCC', 'HAVE_CC_WARNINGS',
	            'HAVE_LONG_DOUBLE', 'HAVE_LONG_LONG', 'HAVE_CYGWIN',
		    'HAVE_LD_NO_UNDEFINED', 'HAVE_LD_STATIC_LIBGCC');

	MkSave(split(' ', $SAVED{'cc'}));
}

BEGIN
{
	$DESCR{'cc'}   = 'a C compiler';
	$TESTS{'cc'}   = \&TEST_cc;
	$DISABLE{'cc'} = \&DISABLE_cc;
	$EMUL{'cc'}    = \&EMUL_cc;
	$SAVED{'cc'}   = 'HAVE_CC HAVE_CC_WARNINGS ' .
	                 'HAVE_CC_CLANG HAVE_CC_GCC HAVE_CC65 HAVE_EMCC ' .
			 'CC CC_COMPILE CFLAGS PICFLAGS EXECSUFFIX ' .
	                 'PROG_GUI_FLAGS PROG_CLI_FLAGS LIBTOOLOPTS_SHARED';

	RegisterEnvVar('CC',       'C compiler command');
	RegisterEnvVar('CFLAGS',   'C compiler flags');
	RegisterEnvVar('LDFLAGS',  'C linker flags');
	RegisterEnvVar('LIBS',     'Libraries to link against');
	RegisterEnvVar('CPP',      'C preprocessor');
	RegisterEnvVar('CPPFLAGS', 'C preprocessor flags');
}
;1
