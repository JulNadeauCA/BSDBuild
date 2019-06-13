# vim:ts=4
# Public domain

sub TEST_objc
{
	my @objc_try = ('clang', 'clang70', 'clang60',
                    'gcc', 'gcc-6', 'gcc7', 'gcc8', 'gcc5', 'gcc49', 'gcc48',
                    'clang.exe', 'cc.exe', 'gcc.exe');
	
	MkIfTrue('$CROSS_COMPILING');
		MkDefine('CROSSPFX', '${host}-');
	MkElse;
		MkDefine('CROSSPFX', '');
	MkEndif;
	
	MkIfEQ('$OBJC', '');										# Unspecified OBJC
		MkPushIFS('$PATH_SEPARATOR');
		MkFor('i', '$PATH');
	my @try = @objc_try;
	my $objc = shift(@try);
			MkIf('-x "${i}/${CROSSPFX}'.$objc.'"');
			MkDefine('OBJC', '${i}/${CROSSPFX}'.$objc);
			MkBreak;
	foreach $objc (@try) {
			MkElif('-x "${i}/${CROSSPFX}'.$objc.'"');
			MkDefine('OBJC', '${i}/${CROSSPFX}'.$objc);
			MkBreak;
	}
			MkEndif;
		MkDone;
		MkPopIFS();

	print << 'EOF';
	if [ "$OBJC" = '' ]; then
	    echo "*"
EOF
	print 'echo "* Cannot find one of ' . join(', ',@objc_try) . '"', "\n";
	print << 'EOF';
		echo "* under the current PATH, which is:"
		echo "* $PATH"
		echo "*"
	    echo "* You may need to set the OBJC environment variable."
	    echo "*"
	    echo "Cannot find Objective C compiler in PATH." >>config.log
		HAVE_OBJC="no"
		echo "no"
	else
		HAVE_OBJC="yes"
		echo "yes, ${OBJC}"
		echo "yes, ${OBJC}" >>config.log
	fi
else
	HAVE_OBJC="yes"
	echo "using ${OBJC}"
fi

if [ "${HAVE_OBJC}" = "yes" ]; then
	$ECHO_N 'checking whether the Objective-C compiler works...'
	$ECHO_N '# checking whether the Objective-C compiler works...' >>config.log
	cat << 'EOT' > conftest.m
#import <stdio.h>
int main(int argc, char *argv[]) { return (0); }
EOT
	$OBJC -x objective-c -o conftest conftest.m 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compilation failed" >>config.log
		HAVE_OBJC="no"
	else
		HAVE_OBJC="yes"
	fi
	
	if [ "${HAVE_OBJC}" = "yes" ]; then
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
				echo "yes, it outputs $EXECSUFFIX files" >>config.log
			else
				echo "yes"
				echo "yes" >>config.log
			fi
EOF
	MkSaveMK('EXECSUFFIX');
	MkSaveDefine('EXECSUFFIX');
	print << 'EOF';
		else
			echo "yes"
			echo "yes" >>config.log
		fi
	fi
	if [ "${keep_conftest}" != "yes" ]; then
		rm -f conftest.m conftest$EXECSUFFIX
	fi
	TEST_OBJCFLAGS=''
fi
EOF
	
	MkIfTrue('${HAVE_OBJC}');
		MkPrintSN('objc: checking for compiler warning options...');
		MkCompileOBJC('HAVE_OBJC_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
		MkIfTrue('${HAVE_OBJC_WARNINGS}');
			MkDefine('TEST_OBJCFLAGS', '-Wall -Werror');
		MkEndif;
		MkSaveDefine('HAVE_OBJC');
		print 'rm -f conftest.m $testdir/conftest$EXECSUFFIX', "\n";
	MkElse;
		DISABLE_objc();
	MkEndif;
}

sub DISABLE_objc
{
	MkDefine('HAVE_OBJC', 'no');
	MkDefine('HAVE_OBJC_WARNINGS', 'no');
	MkDefine('TEST_OBJCFLAGS', '');
	MkSaveUndef('HAVE_OBJC', 'HAVE_OBJC_WARNINGS');
	MkSaveMK('HAVE_OBJC', 'HAVE_OBJC_WARNINGS');
}

BEGIN
{
	my $n = 'objc';

	$DESCR{$n}   = 'Objective-C compiler';
	$TESTS{$n}   = \&TEST_objc;
	$DISABLE{$n} = \&DISABLE_objc;
	$DEPS{$n}    = 'cc';
}
;1
