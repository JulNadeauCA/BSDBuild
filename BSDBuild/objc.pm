# vim:ts=4
#
# Copyright (c) 2002-2016 Hypertriton, Inc. <http://hypertriton.com/>
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

sub Test_Objc
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
	    echo "Cannot find Objective C compiler in PATH." >> config.log
		HAVE_OBJC="no"
		echo "no"
	else
		HAVE_OBJC="yes"
		echo "yes, ${OBJC}"
		echo "yes, ${OBJC}" >> config.log
	fi
else
	HAVE_OBJC="yes"
	echo "using ${OBJC}"
fi

if [ "${HAVE_OBJC}" = "yes" ]; then
	$ECHO_N 'checking whether the Objective-C compiler works...'
	$ECHO_N 'checking whether the Objective-C compiler works...' >> config.log
	cat << 'EOT' > conftest.m
#import <stdio.h>
int main(int argc, char *argv[]) { return (0); }
EOT
	$OBJC -x objective-c -o conftest conftest.m 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no, compile failed" >> config.log
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

		Disable_Objc();

	MkEndif;
}

sub Disable_Objc
{
	MkDefine('HAVE_OBJC', 'no');
	MkDefine('HAVE_OBJC_WARNINGS', 'no');
	MkDefine('OBJC', '');
	MkDefine('OBJCFLAGS', '');
	
	MkSaveUndef('HAVE_OBJC', 'HAVE_OBJC_WARNINGS');

	MkSaveMK('HAVE_OBJC', 'HAVE_OBJC_WARNINGS', 'OBJC', 'OBJCFLAGS');
}

BEGIN
{
	$DESCR{'objc'} = 'Objective-C compiler';
	$DEPS{'objc'}  = 'cc';

	$TESTS{'objc'}   = \&Test_Objc;
	$DISABLE{'objc'} = \&Disable_Objc;
}

;1
