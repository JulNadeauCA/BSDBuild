# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/au.h>

int main(int argc, char *argv[]) {
	AU_InitSubsystem();
	AU_DestroySubsystem();
	return (0);
}
EOF

sub TEST_agar_au
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-au-config', '--version', 'AGAR_AU_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_AU_VERSION');
		MkPrintSN('checking whether agar-au works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-au-config', '--cflags', 'AGAR_AU_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-au-config', '--libs', 'AGAR_AU_LIBS');
		MkCompileC('HAVE_AGAR_AU',
		           '${AGAR_AU_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_AU_LIBS} ${AGAR_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_AGAR_AU}', 'AGAR_AU_CFLAGS', 'AGAR_AU_LIBS');
	MkElse;
		DISABLE_agar_au();
	MkEndif;
}

sub DISABLE_agar_au
{
	MkDefine('HAVE_AGAR_AU', 'no');
	MkDefine('AGAR_AU_CFLAGS', '');
	MkDefine('AGAR_AU_LIBS', '');
	MkSaveUndef('HAVE_AGAR_AU');
}

sub EMUL_agar_au
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_AU', 'ag_au');
	} else {
		MkEmulUnavail('AGAR_AU');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-au';

	$DESCR{$n}   = 'Agar-AU';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_au;
	$DISABLE{$n} = \&DISABLE_agar_au;
	$EMUL{$n}    = \&EMUL_agar_au;

	$DEPS{$n}    = 'cc,agar';
}
;1
