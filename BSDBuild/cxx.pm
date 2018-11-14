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

sub Test
{
	print << 'EOF';
if [ "$CROSS_COMPILING" = "yes" ]; then
	CROSSPFX="${host}-"
else
	CROSSPFX=''
fi
if [ "$CXX" = '' ]; then
	bb_save_IFS=$IFS
	IFS=$PATH_SEPARATOR
	for i in $PATH; do
		if [ -x "${i}/${CROSSPFX}c++" ]; then
			CXX="${i}/${CROSSPFX}c++"
			break
		elif [ -x "${i}/${CROSSPFX}clang++" ]; then
			CXX="${i}/${CROSSPFX}clang++"
			break
		elif [ -x "${i}/${CROSSPFX}gcc" ]; then
			CXX="${i}/${CROSSPFX}gcc"
			break
		elif [ -x "${i}/${CROSSPFX}clang" ]; then
			CXX="${i}/${CROSSPFX}clang"
			break
		elif [ -e "${i}/${CROSSPFX}c++.exe" ]; then
			CXX="${i}/${CROSSPFX}c++.exe"
			break
		elif [ -e "${i}/${CROSSPFX}gcc.exe" ]; then
			CXX="${i}/${CROSSPFX}gcc.exe"
			break
		elif [ -e "${i}/${CROSSPFX}clang.exe" ]; then
			CXX="${i}/${CROSSPFX}clang.exe"
			break
		fi
	done
	IFS=$bb_save_IFS

	if [ "$CXX" = '' ]; then
		echo "*"
		echo "* Cannot find ${CROSSPFX}c++ or ${CROSSPFX}gcc in default PATH."
		echo "* You may need to set the CXX environment variable."
		echo "*"
		echo "Cannot find ${CROSSPFX}c++ or ${CROSSPFX}gcc in PATH." >> config.log
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

	MkElse; # !HAVE_CXX

		MkSaveUndef('HAVE_CXX', 'HAVE_CXX_WARNINGS');

		MkDefine('CXX', '');
		MkDefine('CXXFLAGS', '');
		MkDefine('HAVE_CXX_WARNINGS', 'no');

		MkSaveMK('HAVE_CXX', 'HAVE_CXX_WARNINGS', 'CXX', 'CXXFLAGS');

	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	return (1);
}

BEGIN
{
	$TESTS{'cxx'} = \&Test;
	$EMUL{'cxx'} = \&Emul;
	$DESCR{'cxx'} = 'a C++ compiler';
	$DEPS{'cxx'} = 'cc';
	
	RegisterEnvVar('CXX',		'C++ compiler command');
	RegisterEnvVar('CXXFLAGS',	'C++ compiler flags');
	RegisterEnvVar('CXXCPP',	'C++ preprocessor');
}

;1
