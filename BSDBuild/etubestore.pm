# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <etubestore/ets/ets.h>
int main(int argc, char *argv[]) {
	ETS_Item *it;
	ETS_Init(0);
	it = ETS_ItemNew(NULL);
	ETS_Destroy();
	return (it != NULL);
}
EOF

sub TEST_etubestore
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'etubestore-config', '--version', 'ETUBESTORE_VERSION');
	MkIfFound($pfx, $ver, 'ETUBESTORE_VERSION');
		MkPrintSN('checking whether libetubestore works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'etubestore-config', '--cflags', 'ETUBESTORE_CFLAGS');
		MkExecOutputPfx($pfx, 'etubestore-config', '--libs', 'ETUBESTORE_LIBS');
		MkCompileC('HAVE_ETUBESTORE',
		           '${ETUBESTORE_CFLAGS} ${AGAR_CFLAGS}',
				   '${ETUBESTORE_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkSave('ETUBESTORE_CFLAGS', 'ETUBESTORE_LIBS');
	MkElse;
		DISABLE_etubestore();
	MkEndif;
}

sub DISABLE_etubestore
{
	MkDefine('HAVE_ETUBESTORE', 'no');
	MkDefine('ETUBESTORE_CFLAGS', '');
	MkDefine('ETUBESTORE_LIBS', '');
	MkSaveUndef('HAVE_ETUBESTORE');
}

BEGIN
{
	my $n = 'etubestore';

	$DESCR{$n}   = 'ElectronTubeStore API';
	$URL{$n}     = 'https://electrontubestore.com';
	$TESTS{$n}   = \&TEST_etubestore;
	$DISABLE{$n} = \&DISABLE_etubestore;
	$DEPS{$n}    = 'cc,agar';
}
;1
