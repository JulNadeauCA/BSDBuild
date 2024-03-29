# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>
#include <agar/map.h>

int main(int argc, char *argv[]) {
	MAP *m;
	if (AG_InitCore(NULL, 0) == -1) { return (1); }
	m = MAP_New(NULL, "foo");
	AG_ObjectDestroy(m);
	AG_Destroy();
	return (0);
}
EOF

sub TEST_agar_map
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-map-config', '--version', 'AGAR_MAP_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_MAP_VERSION');
		MkPrintSN('checking whether Agar-MAP works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-map-config', '--cflags', 'AGAR_MAP_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-map-config', '--libs', 'AGAR_MAP_LIBS');

		MkCompileC('HAVE_AGAR_MAP', '${AGAR_MAP_CFLAGS} ${AGAR_CFLAGS}',
		                            '${AGAR_MAP_LIBS} ${AGAR_LIBS}',
		                            $testCode);
		MkIfFalse('${HAVE_AGAR_MAP}');
			MkDisableFailed('agar-map');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-map');
	MkEndif;
}

sub DISABLE_agar_map
{
	MkDefine('HAVE_AGAR_MAP', 'no') unless $TestFailed;
	MkDefine('AGAR_MAP_CFLAGS', '');
	MkDefine('AGAR_MAP_LIBS', '');
	MkSaveUndef('HAVE_AGAR_MAP');
}

BEGIN
{
	my $n = 'agar-map';

	$DESCR{$n}   = 'Agar-MAP';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_map;
	$DISABLE{$n} = \&DISABLE_agar_map;
	$DEPS{$n}    = 'cc,agar';
	$SAVED{$n}   = 'AGAR_MAP_CFLAGS AGAR_MAP_LIBS';
}
;1
