# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <edacious/core.h>

int main(int argc, char *argv[]) {
	ES_Circuit *ckt;
	ckt = ES_CircuitNew(NULL, "foo");
	ES_CircuitLog(ckt, "foo");
	return (0);
}
EOF

sub TEST_edacious
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'edacious-config', '--version', 'EDACIOUS_VERSION');
	MkIfFound($pfx, $ver, 'EDACIOUS_VERSION');
		MkPrintSN('checking whether Edacious works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkExecOutputPfx($pfx, 'edacious-config', '--cflags', 'EDACIOUS_CFLAGS');
		MkExecOutputPfx($pfx, 'edacious-config', '--libs', 'EDACIOUS_LIBS');
		MkCompileC('HAVE_EDACIOUS',
		           '${EDACIOUS_CFLAGS} ${AGAR_MATH_CFLAGS} ${AGAR_VG_CFLAGS} '.
		           '${AGAR_CFLAGS}',
		           '${EDACIOUS_LIBS} ${AGAR_MATH_LIBS} ${AGAR_VG_LIBS} '.
		           '${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_EDACIOUS}', 'EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
	MkElse;
		MkSaveUndef('HAVE_EDACIOUS');
	MkEndif;
}

sub DISABLE_edacious
{
	MkDefine('HAVE_EDACIOUS', 'no');
	MkDefine('EDACIOUS_CFLAGS', '');
	MkDefine('EDACIOUS_LIBS', '');
	MkSaveUndef('HAVE_EDACIOUS');
}

BEGIN
{
	my $n = 'edacious';

	$DESCR{$n}   = 'Edacious';
	$URL{$n}     = 'http://edacious.org';
	$TESTS{$n}   = \&TEST_edacious;
	$DISABLE{$n} = \&DISABLE_edacious;
	$DEPS{$n}    = 'cc,agar,agar-vg,agar-math';
}
;1
