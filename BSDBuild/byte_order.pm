# vim:ts=4
#
# Copyright (c) 2007-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

my $testCode = << 'EOF';
#include <sys/types.h>
#include <sys/param.h>
int
main(int argc, char *argv[])
{
#if BYTE_ORDER == BIG_ENDIAN
	static volatile char *bo = "BiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiANBiGEnDiAN";
#else
	static volatile char *bo = "LiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiANLiTTLeEnDiAN";
#endif
	int c = 0;
	volatile char *p = bo;
	while (*p != '\0') { c *= (int)*p; }
	return (c>123?c:456);
}
EOF

sub Test
{
	MkIfNE('${byte_order}', '');
		MkIfEQ('${byte_order}', 'LE');
			MkDefine('_MK_BYTE_ORDER', 'LE');
		MkElse;
			MkIfEQ('${byte_order}', 'BE');
				MkDefine('_MK_BYTE_ORDER', 'BE');
			MkElse;
				MkFail('Usage: --byte-order=[LE|BE]');
			MkEndif;
		MkEndif;
	MkElse;
		print << "EOF";
cat << EOT > conftest.c
$testCode
EOT
echo "\$CC \$CFLAGS $cflags -o \$testdir/conftest conftest.c" >>config.log
\$CC \$CFLAGS $cflags -o \$testdir/conftest conftest.c 2>>config.log
if [ \$? != 0 ]; then
	echo "Failed to compile test for byte order, code \$?"
	echo "Failed to compile test for byte order, code \$?" >> config.log
	exit 1
fi
rm -f conftest.c

_MK_BYTE_ORDER=''
_MK_BYTE_ORDER_LESTRING='LiTTLeEnD'
_MK_BYTE_ORDER_BESTRING='BiGEnDiAN'
od -tc \$testdir/conftest\$EXECSUFFIX | sed 's/ //g' > \$testdir/conftest.dump

if grep "\$_MK_BYTE_ORDER_LESTRING" \$testdir/conftest.dump >/dev/null; then
	_MK_BYTE_ORDER="LE"
	if grep "\$_MK_BYTE_ORDER_BESTRING" \$testdir/conftest.dump >/dev/null; then
		echo '*'
		echo '* Unable to auto-determine host byte order. Please re-run ./configure'
		echo '* with --byte-order=LE or --byte-order=BE.'
		echo '*'
		exit 1
	fi
else
	if grep "\$_MK_BYTE_ORDER_BESTRING" \$testdir/conftest.dump >/dev/null; then
		_MK_BYTE_ORDER="BE"
		if grep "\$_MK_BYTE_ORDER_LESTRING" \$testdir/conftest.dump >/dev/null; then
			echo '*'
			echo '* Unable to auto-determine host byte order. Please re-run ./configure'
			echo '* with --byte-order=LE or --byte-order=BE.'
			echo '*'
			exit 1
		fi
	fi
fi
rm -f conftest.c \$testdir/conftest$EXECSUFFIX \$testdir/conftest.dump
EOF
	MkEndif;
	
	MkIfEQ('$_MK_BYTE_ORDER', 'LE');
		MkPrintS('little-endian');
		MkDefine('_MK_LITTLE_ENDIAN', 'yes');
		MkSaveDefine('_MK_LITTLE_ENDIAN');
		MkSaveUndef('_MK_BIG_ENDIAN');
	MkElse;
		MkPrintS('big-endian');
		MkDefine('_MK_BIG_ENDIAN', 'yes');
		MkSaveDefine('_MK_BIG_ENDIAN');
		MkSaveUndef('_MK_LITTLE_ENDIAN');
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($machine =~ /^(hppa|m68k|mc68000|mips|mipseb|ppc|sparc|sparc64)$/) {
		MkDefine('_MK_BIG_ENDIAN', 'yes');
		MkSaveDefine('_MK_BIG_ENDIAN');
		MkSaveUndef('_MK_LITTLE_ENDIAN');
	} else {
		MkDefine('_MK_LITTLE_ENDIAN', 'yes');
		MkSaveDefine('_MK_LITTLE_ENDIAN');
		MkSaveUndef('_MK_BIG_ENDIAN');
	}
	return (1);
}

BEGIN
{
	$TESTS{'byte_order'} = \&Test;
	$DEPS{'byte_order'} = 'cc';
	$EMUL{'byte_order'} = \&Emul;
	$DESCR{'byte_order'} = 'byte order';
}

;1
