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
	# Look for an Objective-C compiler.
	# XXX duplicated code between cc/cxx/objc
	#
	print << 'EOF';
if [ "$OBJC" = "" ]; then
	if [ "$CC" != "" ]; then
		OBJC="$CC"
		HAVE_OBJC="yes"
		echo "using CC (${OBJC})"
	else
		for i in `echo $PATH |sed 's/:/ /g'`; do
			if [ -x "${i}/cc" ]; then
				if [ -f "${i}/cc" ]; then
					OBJC="${i}/cc"
					break
				fi
			elif [ -x "${i}/gcc" ]; then
				if [ -f "${i}/gcc" ]; then
					OBJC="${i}/gcc"
					break
				fi
			fi
		done
		if [ "$OBJC" = "" ]; then
			echo "*"
			echo "* Unable to find an Objective-C compiler in PATH. You may need"
			echo "* to set the CC or OBJC environment variable."
			echo "*"
			echo "Unable to find an Objective-C compiler in PATH." >> config.log
			HAVE_OBJC="no"
			echo "no"
		else
			HAVE_OBJC="yes"
			echo "yes, ${OBJC}"
			echo "yes, ${OBJC}" >> config.log
		fi
	fi
else
	HAVE_OBJC="yes"
	echo "using ${OBJC}"
fi

if [ "${HAVE_OBJC}" = "yes" ]; then
	$ECHO_N "checking whether the Objective-C compiler works..."
	$ECHO_N "checking whether the Objective-C compiler works..." >> config.log
	cat << 'EOT' > conftest.m
#import <stdio.h>
int main(int argc, char *argv[]) { return (0); }
EOT
	$OBJC -x objective-c -o conftest conftest.m 2>>config.log
	if [ $? != 0 ]; then
	    echo "no"
	    echo "no (test failed to compile)" >> config.log
		HAVE_OBJC="no"
	else
		echo "yes"
		echo "yes" >> config.log
		HAVE_OBJC="yes"
	fi
	
	if [ "${HAVE_OBJC}" = "yes" ]; then
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
	rm -f conftest.m conftest$EXECSUFFIX
	TEST_OBJCFLAGS=""
fi
EOF
	
	MkIfTrue('${HAVE_OBJC}');
		MkPrintN('checking for compiler warning options...');
		MkCompileOBJC('HAVE_OBJC_WARNINGS', '-Wall -Werror', '', << 'EOF');
int main(int argc, char *argv[]) { return (0); }
EOF
		MkIfTrue('${HAVE_OBJC_WARNINGS}');
			MkDefine('TEST_OBJCFLAGS', '-Wall -Werror');
		MkEndif;
	
		MkPrintN('checking for libtool --tag=OBJC retardation...');
		my $code = << 'EOF';
EOF
		print 'cat << EOT > conftest.m', "\n",
		      'int main(int argc, char *argv[]) { return (0); }', "\nEOT\n";
		print << "EOF";
\$LIBTOOL --quiet --mode=compile --tag=OBJC \$OBJC \$CFLAGS \$OBJCFLAGS \$TEST_OBJCFLAGS -o \$testdir/conftest.o conftest.m 2>>config.log
EOF
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkDefine('LIBTOOLOPTS_OBJC', '--tag=OBJC');
		MkElse;
			MkPrint('no');
		MkEndif;
		MkSaveMK('LIBTOOLOPTS_OBJC');
		print 'rm -f conftest.m $testdir/conftest$EXECSUFFIX', "\n";

		# Preserve ${OBJC} and ${OBJCFLAGS}
		MkSaveMK('OBJC', 'OBJCFLAGS');

	MkEndif; # HAVE_OBJC
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	return (1);
}

BEGIN
{
	$TESTS{'objc'} = \&Test;
	$EMUL{'objc'} = \&Emul;
	$DESCR{'objc'} = 'an Objective-C compiler';
}

;1
