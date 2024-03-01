# Public domain

sub TEST_cxx
{
	my @cxx_try = ('clang++', 'clang++70', 'clang++60', 'c++',
	               'gcc', 'gcc-6', 'gcc7', 'gcc8', 'gcc5', 'gcc49', 'gcc48',
 	               'clang.exe', 'c++.exe', 'gcc.exe');

	MkIfTrue('$CROSS_COMPILING');
		MkDefine('CROSSPFX', '${host}-');
	MkElse;
		MkDefine('CROSSPFX', '');
	MkEndif;
	
	MkIfEQ('$CXX', '');										# Unspecified CXX
		MkPushIFS('$PATH_SEPARATOR');
		MkFor('i', '$PATH');
			my @try = @cxx_try;
			my $cxx = shift(@try);

			MkIf('-x "${i}/${CROSSPFX}'.$cxx.'"');
			MkDefine('CXX', '${i}/${CROSSPFX}'.$cxx);
			MkBreak;

			foreach $cxx (@try) {
				MkElif('-x "${i}/${CROSSPFX}'.$cxx.'"');
				MkDefine('CXX', '${i}/${CROSSPFX}'.$cxx);
				MkBreak;
			}

			MkEndif;
		MkDone;
		MkPopIFS();

	print << 'EOF';
	if [ "$CXX" = '' ]; then
		echo "*"
EOF
	print 'echo "* Cannot find one of ' . join(', ',@cxx_try) . '"', "\n";
	print << 'EOF';
		echo "* under the current PATH, which is:"
		echo "* $PATH"
		echo "*"
		echo "* You may need to set the CXX environment variable."
		echo "*"
		echo "Cannot find C++ compiler in PATH." >>config.log
		HAVE_CXX="no"
		echo "no"
	else
		HAVE_CXX="yes"
		echo "yes, ${CXX}"
		echo "yes, ${CXX}" >>config.log
	fi
else
	HAVE_CXX="yes"
	echo "using ${CXX}"
fi

if [ "${HAVE_CXX}" = "yes" ]; then
	$ECHO_N 'checking whether the C++ compiler works...'
	$ECHO_N '# checking whether the C++ compiler works...' >>config.log
	cat << 'EOT' > conftest.cc
#include <iostream>
int main(void) { std::cout << "Hello world!" << std::endl; return 0; }
EOT
	$CXX -o conftest conftest.cc -lstdc++ 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compilation failed" >>config.log
		HAVE_CXX="no"
	else
		HAVE_CXX="yes"
	fi

	if [ "${HAVE_CXX}" = "yes" ]; then
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
	MkSaveDefine('EXECSUFFIX');
print << 'EOF';
		else
			echo "yes"
			echo "yes" >>config.log
		fi
	fi
	if [ "${keep_conftest}" != "yes" ]; then
		rm -f conftest.cc conftest$EXECSUFFIX
	fi
	TEST_CXXFLAGS=''
fi
EOF

	MkIfTrue('${HAVE_CXX}');

		MkPrintSN('cxx: checking for compiler warning options...');
		MkCompileCXX('HAVE_CXX_WARNINGS', '-Wall', '-lstdc++', << 'EOF');
int main(void) { return (0); }
EOF
		MkIfTrue('${HAVE_CXX_WARNINGS}');
			MkDefine('TEST_CXXFLAGS', '-Wall');
		MkEndif;

		print 'rm -f conftest.cc $testdir/conftest$EXECSUFFIX', "\n";
	MkElse;
		MkDisableFailed('cxx');
	MkEndif;
}

sub DISABLE_cxx
{
	MkDefine('HAVE_CXX', 'no') unless $TestFailed;
	MkDefine('HAVE_CXX_WARNINGS', 'no');
	MkDefine('TEST_CXXFLAGS', '');
	MkDefine('EXECSUFFIX', '');
	MkSaveDefine('EXECSUFFIX');
	MkSaveUndef('HAVE_CXX', 'HAVE_CXX_WARNINGS');
}

BEGIN
{
	my $n = 'cxx';

	$DESCR{$n}   = 'a C++ compiler';
	$TESTS{$n}   = \&TEST_cxx;
	$DISABLE{$n} = \&DISABLE_cxx;
	$DEPS{$n}    = '';
	$SAVED{$n}   = 'HAVE_CXX HAVE_CXX_WARNINGS CXX CXXFLAGS EXECSUFFIX';
	
	RegisterEnvVar('CXX',      'C++ compiler command');
	RegisterEnvVar('CXXFLAGS', 'C++ compiler flags');
	RegisterEnvVar('CXXCPP',   'C++ preprocessor');
}
;1
