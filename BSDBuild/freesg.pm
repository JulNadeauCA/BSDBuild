# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <freesg/sg.h>

int main(int argc, char *argv[]) {
	SG *sg;
	sg = SG_New(NULL, "foo", 0);
	AG_ObjectDestroy(sg);
	return (0);
}
EOF

sub TEST_freesg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'freesg-config', '--version', 'FREESG_VERSION');
	MkIfFound($pfx, $ver, 'FREESG_VERSION');
		MkPrintSN('checking whether FreeSG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'freesg-config', '--cflags', 'FREESG_CFLAGS');
		MkExecOutputPfx($pfx, 'freesg-config', '--libs', 'FREESG_LIBS');
		MkCompileC('HAVE_FREESG',
		           '${FREESG_CFLAGS} ${AGAR_CFLAGS}',
		           '${FREESG_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_FREESG}', 'FREESG_CFLAGS', 'FREESG_LIBS');
	MkElse;
		DISABLE_freesg();
	MkEndif;
}

sub DISABLE_freesg
{
	MkDefine('HAVE_FREESG', 'no');
	MkDefine('FREESG_CFLAGS', '');
	MkDefine('FREESG_LIBS', '');
	MkSaveUndef('HAVE_FREESG', 'FREESG_CFLAGS', 'FREESG_LIBS');
}

sub EMUL_freesg
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREESG', 'freesg_pe freesg glu');
	} else {
		MkEmulUnavail('FREESG');
	}
	return (1);
}

BEGIN
{
	my $n = 'freesg';

	$DESCR{$n}   = 'FreeSG';
	$URL{$n}     = 'http://FreeSG.org';
	$TESTS{$n}   = \&TEST_freesg;
	$DISABLE{$n} = \&DISABLE_freesg;
	$EMUL{$n}    = \&EMUL_freesg;
	$DEPS{$n}    = 'cc,agar';

	@{$EMULDEPS{$n}} = qw(agar);
}
;1
