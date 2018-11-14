# Public domain
# vim:ts=4

my $adaHello = << 'EOF';
with Ada.Text_IO; use Ada.Text_IO;
procedure conftest is
begin
	Put_Line ("Hello, world!");
end conftest;
EOF

sub Test_Ada
{
	print << 'EOF';
TEST_ADAFLAGS=''
if [ "$CROSS_COMPILING" = "yes" ]; then
	CROSSPFX="${host}-"
else
	CROSSPFX=''
fi
if [ "$ADA" = '' ]; then
	bb_save_IFS=$IFS
	IFS=$PATH_SEPARATOR
	for i in $PATH; do
		if [ -x "${i}/${CROSSPFX}ada" ]; then
			ADA="${i}/${CROSSPFX}ada"
			break
		elif [ -e "${i}/${CROSSPFX}ada.exe" ]; then
			ADA="${i}/${CROSSPFX}ada.exe"
			break
		elif [ -x "${i}/${CROSSPFX}gcc" ]; then
			ADA="${i}/${CROSSPFX}gcc"
			break
		elif [ -e "${i}/${CROSSPFX}gcc.exe" ]; then
			ADA="${i}/${CROSSPFX}gcc.exe"
			break
		fi
	done
	IFS=$bb_save_IFS

	if [ "$ADA" = '' ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}ada or ${CROSSPFX}gcc in default PATH."
		echo "* You may need to set the ADA environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}ada or ${CROSSPFX}gcc in PATH." >> config.log
		HAVE_ADA="no"
		echo "no"
	else
		HAVE_ADA="yes"
		echo "yes, ${ADA}"
		echo "yes, ${ADA}" >> config.log
	fi
else
	HAVE_ADA="yes"
	echo "using ${ADA}"
fi
$ECHO_N "ada: checking for Ada binder..."
if [ "$ADABIND" = '' ]; then
	bb_save_IFS=$IFS
	IFS=$PATH_SEPARATOR
	for i in $PATH; do
		if [ -x "${i}/${CROSSPFX}gnatbind" ]; then
			ADABIND="${i}/${CROSSPFX}gnatbind"
			break
		elif [ -e "${i}/${CROSSPFX}gnatbind.exe" ]; then
			ADABIND="${i}/${CROSSPFX}gnatbind.exe"
			break
		fi
	done
	IFS=$bb_save_IFS

	if [ "$ADABIND" = '' ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}gnatbind in default PATH."
		echo "* You may need to set the ADABIND environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}gnatbind in PATH." >> config.log
		echo "no"
	else
		echo "yes, ${ADABIND}"
		echo "yes, ${ADABIND}" >> config.log
	fi
else
	echo "using ${ADABIND}"
	echo "using ${ADABIND}" >> config.log
fi
$ECHO_N "ada: checking for Ada linker..."
if [ "$ADALINK" = '' ]; then
	bb_save_IFS=$IFS
	IFS=$PATH_SEPARATOR
	for i in $PATH; do
		if [ -x "${i}/${CROSSPFX}gnatlink" ]; then
			ADALINK="${i}/${CROSSPFX}gnatlink"
			break
		elif [ -e "${i}/${CROSSPFX}gnatlink.exe" ]; then
			ADALINK="${i}/${CROSSPFX}gnatlink.exe"
			break
		fi
	done
	IFS=$bb_save_IFS

	if [ "$ADALINK" = '' ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}gnatlink in default PATH."
		echo "* You may need to set the ADALINK environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}gnatlink in PATH." >> config.log
		echo "no"
	else
		echo "yes, ${ADALINK}"
		echo "yes, ${ADALINK}" >> config.log
	fi
else
	echo "using ${ADALINK}"
	echo "using ${ADALINK}" >> config.log
fi

$ECHO_N "ada: checking for Ada mkdep..."
if [ "$ADAMKDEP" = '' ]; then
	bb_save_IFS=$IFS
	IFS=$PATH_SEPARATOR
	for i in $PATH; do
		if [ -x "${i}/${CROSSPFX}gnatmake" ]; then
			ADAMKDEP="${i}/${CROSSPFX}gnatmake"
			break
		elif [ -e "${i}/${CROSSPFX}gnatmake.exe" ]; then
			ADAMKDEP="${i}/${CROSSPFX}gnatmake.exe"
			break
		fi
	done
	IFS=$bb_save_IFS

	if [ "$ADAMKDEP" = '' ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}gnatmake in default PATH."
		echo "* You may need to set the ADAMKDEP environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}gnatlink in PATH." >> config.log
		echo "no"
	else
		echo "yes, ${ADAMKDEP} -M"
		echo "yes, ${ADAMKDEP} -M" >> config.log
	fi
else
	echo "using ${ADAMKDEP} -M"
	echo "using ${ADAMKDEP} -M" >> config.log
fi

if [ "${HAVE_ADA}" = "yes" ]; then
	$ECHO_N 'checking whether the Ada compiler works...'
	$ECHO_N 'checking whether the Ada compiler works...' >> config.log
	cat << 'EOT' > conftest.adb
EOF
	print $adaHello;
print << 'EOF';
EOT
	$ADA -c conftest.adb 2>>config.log
	if [ $? != 0 ]; then
	    echo "no (compile failed)"
	    echo "no, compile failed" >> config.log
		HAVE_ADA="no"
	else
		$ADABIND conftest 2>>config.log
		if [ $? != 0 ]; then
		    echo "no (binder failed)"
		    echo "no, binder failed" >> config.log
			HAVE_ADA="no"
		else
			$ADALINK conftest 2>>config.log
			if [ $? != 0 ]; then
				echo "no (linker failed)"
				echo "no, linker failed" >> config.log
				HAVE_ADA="no"
			else
				HAVE_ADA="yes"
			fi
		fi
	fi

	if [ "${HAVE_ADA}" = "yes" ]; then
		if [ "${EXECSUFFIX}" = '' ]; then
			EXECSUFFIX=''
			for OUTFILE in conftest.exe conftest conftest.*; do
				if [ -f $OUTFILE ]; then
					case $OUTFILE in
					*.adb | *.ali | *.o | *.obj | *.bb | *.bbg | *.d | *.pdb | *.tds | *.xcoff | *.dSYM | *.xSYM )
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
		rm -f conftest.adb conftest.ali conftest.o conftest$EXECSUFFIX
		rm -f "b~conftest.adb" "b~conftest.ads"
	fi
	TEST_ADAFLAGS=''
fi
EOF
	
	MkIfTrue('${HAVE_ADA}');
		MkPrintSN('ada: checking for -mwindows option...');
		TryCompileFlagsAda('HAVE_ADA_MWINDOWS', '-mwindows', $adaHello);
		MkIfTrue('${HAVE_ADA_MWINDOWS}');
			MkDefine('PROG_GUI_FLAGS', '-mwindows');
		MkElse;
			MkDefine('PROG_GUI_FLAGS', '');
		MkEndif;
		
		MkPrintSN('ada: checking for -mconsole option...');
		TryCompileFlagsC('HAVE_ADA_MCONSOLE', '-mconsole', << 'EOF');
#include <windows.h>
int
main(int argc, char *argv[]) {
	return GetFileAttributes("foo") ? 0 : 1;
}
EOF
		MkIfTrue('${HAVE_ADA_MCONSOLE}');
			MkDefine('PROG_CLI_FLAGS', '-mconsole');
		MkElse;
			MkDefine('PROG_CLI_FLAGS', '');
		MkEndif;
		
		MkCaseIn('${host}');
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkPrintSN('ada: checking for linker -no-undefined option...');
			TryCompileFlagsAda('HAVE_ADA_LD_NO_UNDEFINED', '-Wl,--no-undefined', $adaHello);
			MkIfTrue('${HAVE_ADA_LD_NO_UNDEFINED}');
				MkDefine('LIBTOOLOPTS_SHARED',
				    '${LIBTOOLOPTS_SHARED} -no-undefined -Wl,--no-undefined');
			MkEndif;
			MkPrintSN('ada: checking for linker -static-libgcc option...');
			TryCompileFlagsAda('HAVE_ADA_LD_STATIC_LIBGCC', '-static-libgcc', $adaHello);
			MkIfTrue('${HAVE_ADA_LD_STATIC_LIBGCC}');
				MkDefine('LIBTOOLOPTS_SHARED', '${LIBTOOLOPTS_SHARED} ' .
				                               '-XCClinker -static-libgcc');
			MkEndif;
			MkCaseEnd;
		MkEsac;

		MkSaveMK('ADA', 'ADAFLAGS', 'ADABIND', 'ADABFLAGS', 'ADALINK', 'ADALFLAGS',
		         'ADAMKDEP', 'PROG_GUI_FLAGS', 'PROG_CLI_FLAGS',
		         'LIBTOOLOPTS_SHARED');
	MkElse;
		Disable_Ada();
	MkEndif;
}

sub Disable_Ada
{
	MkDefine('HAVE_ADA', 'no');

	MkDefine('ADA',       '');
	MkDefine('ADAFLAGS',  '');
	MkDefine('ADABIND',   '');
	MkDefine('ADABFLAGS', '');
	MkDefine('ADALINK',   '');
	MkDefine('ADALFLAGS', '');
	MkDefine('ADAMKDEP',  '');

	MkSaveMK('ADA', 'ADAFLAGS',
             'ADABIND', 'ADABFLAGS',
             'ADALINK', 'ADALFLAGS',
             'ADAMKDEP');

	MkSaveUndef('HAVE_ADA',
	            'HAVE_ADA_LD_NO_UNDEFINED',
                'HAVE_ADA_LD_STATIC_LIBGCC');
}

BEGIN
{
	$DESCR{'ada'}   = 'Ada compiler';
	$TESTS{'ada'}   = \&Test_Ada;
	$DISABLE{'ada'} = \&Disable_Ada;

	RegisterEnvVar('ADA',		'Ada compiler command');
	RegisterEnvVar('ADAFLAGS',	'Ada compiler flags');
	RegisterEnvVar('ADABIND',	'Ada binder command');
	RegisterEnvVar('ADABFLAGS',	'Ada binder flags');
	RegisterEnvVar('ADALINK',	'Ada linker command');
	RegisterEnvVar('ADALFLAGS',	'Ada linker flags');
	RegisterEnvVar('ADAMKDEP',	'Ada dependency output command');
	RegisterEnvVar('LIBS',		'Libraries passed to binder');
}
;1
