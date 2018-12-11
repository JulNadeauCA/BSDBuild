# vim:ts=4
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
		MkCompileC('HAVE_GLIB2',
			   '${GLIB2_CFLAGS}', '${GLIB2_LIBS}',
			    $testCode);
		MkSaveIfTrue('${HAVE_GLIB2}', 'GLIB2_CFLAGS', 'GLIB2_LIBS');
	MkElse;
		MkSaveUndef('HAVE_GLIB2');
	MkEndif;
}

sub DISABLE_glib2
{
	MkDefine('HAVE_GLIB2', 'no');
	MkDefine('GLIB2_CFLAGS', '');
	MkDefine('GLIB2_LIBS', '');
	MkSaveUndef('HAVE_GLIB2', 'GLIB2_CFLAGS', 'GLIB2_LIBS');
}

BEGIN
{
	my $n = 'glib2';

	$DESCR{$n}   = 'Glib 2.x';
	$URL{$n}     = 'http://www.gtk.org';
	$TESTS{$n}   = \&TEST_glib2;
	$DISABLE{$n} = \&DISABLE_glib2;
	$DEPS{$n}    = 'cc';
}
;1
