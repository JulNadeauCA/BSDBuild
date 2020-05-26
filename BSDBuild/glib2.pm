# Public domain

my $testCode = << 'EOF';
#include <glib.h>
int main(int argc, char *argv[]) {
	void *slist = g_slist_alloc();
	g_slist_free(slist);
	return (0);
}
EOF

sub TEST_glib2
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'glib-2.0', '--modversion', 'GLIB2_VERSION');
	MkExecPkgConfig($pfx, 'glib-2.0', '--cflags', 'GLIB2_CFLAGS');
	MkExecPkgConfig($pfx, 'glib-2.0', '--libs', 'GLIB2_LIBS');
	MkIfFound($pfx, $ver, 'GLIB2_VERSION');
		MkPrintSN('checking whether glib 2.x works...');
		MkCompileC('HAVE_GLIB2', '${GLIB2_CFLAGS}', '${GLIB2_LIBS}',
			   $testCode);
		MkIfFalse('${HAVE_GLIB2}');
			MkDisableFailed('glib2');
		MkEndif;
	MkElse;
		MkDisableNotFound('glib2');
	MkEndif;
}

sub DISABLE_glib2
{
	MkDefine('HAVE_GLIB2', 'no') unless $TestFailed;
	MkDefine('GLIB2_CFLAGS', '');
	MkDefine('GLIB2_LIBS', '');
	MkSaveUndef('HAVE_GLIB2');
}

BEGIN
{
	my $n = 'glib2';

	$DESCR{$n}   = 'Glib 2.x';
	$URL{$n}     = 'http://www.gtk.org';
	$TESTS{$n}   = \&TEST_glib2;
	$DISABLE{$n} = \&DISABLE_glib2;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'GLIB2_CFLAGS GLIB2_LIBS';
}
;1
