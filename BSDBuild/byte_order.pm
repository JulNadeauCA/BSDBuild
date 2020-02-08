# Public domain
# vim:ts=4

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

sub TEST_byte_order
{
	MkIfNE('${byte_order}', '');
		MkIfEQ('${byte_order}', 'LE');
			MkDefine('_MK_BYTE_ORDER', 'LE');
			MkDefine('_MK_LITTLE_ENDIAN', 'yes');
			MkSaveDefine('_MK_LITTLE_ENDIAN');
			MkSaveUndef('_MK_BIG_ENDIAN');
		MkElse;
			MkIfEQ('${byte_order}', 'BE');
				MkDefine('_MK_BYTE_ORDER', 'BE');
				MkDefine('_MK_BIG_ENDIAN', 'yes');
				MkSaveDefine('_MK_BIG_ENDIAN');
				MkSaveUndef('_MK_LITTLE_ENDIAN');
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

sub EMUL_byte_order
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
	my $n = 'byte_order';

	$DESCR{$n} = 'byte order';
	$TESTS{$n} = \&TEST_byte_order;
	$EMUL{$n}  = \&EMUL_byte_order;
	$DEPS{$n}  = 'cc';
}
;1
