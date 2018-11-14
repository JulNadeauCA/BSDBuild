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

sub Test_AgarAU
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
		           '${AGAR_AU_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_AU}', 'AGAR_AU_CFLAGS', 'AGAR_AU_LIBS');
	MkElse;
		Disable_AgarAU();
	MkEndif;
	return (0);
}

sub Disable_AgarAU
{
	MkSaveUndef('HAVE_AGAR_AU',
	            'AGAR_AU_CFLAGS',
	            'AGAR_AU_LIBS');
}

sub Emul
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

	$DESCR{$n} = 'Agar-AU';
	$URL{$n}   = 'http://libagar.org';
	$DEPS{$n}  = 'cc,agar';

	$TESTS{$n}   = \&Test_AgarAU;
	$DISABLE{$n} = \&Disable_AgarAU;
	$EMUL{$n}    = \&Emul;
}

;1
