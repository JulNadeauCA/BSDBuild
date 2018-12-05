# vim:ts=4
#
# Copyright (c) 2002-2018 Julien Nadeau Carriere <vedge@hypertriton.com>
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

sub Test_CXX
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
		echo "Cannot find C++ compiler in PATH." >> config.log
		HAVE_CXX="no"
		echo "no"
	else
		HAVE_CXX="yes"
		echo "yes, ${CXX}"
		echo "yes, ${CXX}" >> config.log
	fi
else
	HAVE_CXX="yes"
	echo "using ${CXX}"
fi

if [ "${HAVE_CXX}" = "yes" ]; then
	$ECHO_N 'checking whether the C++ compiler works...'
	$ECHO_N 'checking whether the C++ compiler works...' >> config.log
	cat << 'EOT' > conftest.cc
#include <iostream>
int main(void) { std::cout << "Hello world!" << std::endl; return 0; }
EOT
	$CXX -o conftest conftest.cc -lstdc++ 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compile failed" >> config.log
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
		rm -f conftest.cc conftest$EXECSUFFIX
	fi
	TEST_CXXFLAGS=''
fi
EOF

	MkIfTrue('${HAVE_CXX}');

		MkPrintSN('cxx: checking for compiler warning options...');
		MkCompileCXX('HAVE_CXX_WARNINGS', '-Wall -Werror', '-lstdc++', << 'EOF');
int main(void) { return (0); }
EOF
		MkIfTrue('${HAVE_CXX_WARNINGS}');
			MkDefine('TEST_CXXFLAGS', '-Wall -Werror');
		MkEndif;

		print 'rm -f conftest.cc $testdir/conftest$EXECSUFFIX', "\n";

		MkSaveMK('HAVE_CXX', 'CXX', 'CXXFLAGS');

	MkElse;
		Disable_CXX();
	MkEndif;
}

sub Disable_CXX
{
		MkSaveUndef('HAVE_CXX', 'HAVE_CXX_WARNINGS');

		MkDefine('CXX', '');
		MkDefine('CXXFLAGS', '');
		MkDefine('HAVE_CXX_WARNINGS', 'no');

		MkSaveMK('HAVE_CXX', 'HAVE_CXX_WARNINGS', 'CXX', 'CXXFLAGS');
}

BEGIN
{
	$DESCR{'cxx'}	= 'a C++ compiler';
	$TESTS{'cxx'}	= \&Test_CXX;
	$DISABLE{'cxx'}	= \&Disable_CXX;
	$DEPS{'cxx'}	= 'cc';
	
	RegisterEnvVar('CXX',		'C++ compiler command');
	RegisterEnvVar('CXXFLAGS',	'C++ compiler flags');
	RegisterEnvVar('CXXCPP',	'C++ preprocessor');
}

;1
