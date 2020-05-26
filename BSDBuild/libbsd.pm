# Public domain

my $testCode = << 'EOF';
#include <bsd/bsd.h>

int main(int argc, char *argv[]) {
	int size;
	char dst[4];
	char src[3] = "foo";
	size = strlcpy(dst, src, 4);
	return (size < sizeof(src)) ? 0 : 1;
}
EOF

sub TEST_libbsd
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'libbsd', '--modversion', 'LIBBSD_VERSION');
	MkExecPkgConfig($pfx, 'libbsd', '--cflags', 'LIBBSD_CFLAGS');
	MkExecPkgConfig($pfx, 'libbsd', '--libs', 'LIBBSD_LIBS');
	MkIfFound($pfx, $ver, 'LIBBSD_VERSION');
		MkPrintSN('checking whether libbsd works...');
		MkCompileC('HAVE_LIBBSD', '${LIBBSD_CFLAGS}', '${LIBBSD_LIBS}', $testCode);
		MkIfFalse('${HAVE_LIBBSD}');
			MkDisableFailed('libbsd');
		MkEndif;
	MkElse;
		MkDisableNotFound('libbsd');
	MkEndif;
}

sub DISABLE_libbsd
{
	MkDefine('HAVE_LIBBSD', 'no') unless $TestFailed;
	MkDefine('LIBBSD_CFLAGS', '');
	MkDefine('LIBBSD_LIBS', '');
	MkSaveUndef('HAVE_LIBBSD');
}

BEGIN
{
	my $n = 'libbsd';

	$DESCR{$n}   = 'libbsd';
	$URL{$n}     = 'http://libbsd.freedesktop.org';
	$TESTS{$n}   = \&TEST_libbsd;
	$DISABLE{$n} = \&DISABLE_libbsd;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'LIBBSD_CFLAGS LIBBSD_LIBS';
}
;1
