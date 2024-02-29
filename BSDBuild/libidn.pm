# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <idn2.h>

int main(int argc, char *argv[]) {
	char *buf = "foo.com", *p;
	int rv;
	rv = idn2_to_unicode_lzlz(buf, &p, 0);
	return ((rv == IDN2_OK) ? 0 : 1);
}
EOF

sub TEST_libidn
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'libidn2', '--modversion', 'LIBIDN_VERSION');
	MkExecPkgConfig($pfx, 'libidn2', '--cflags', 'LIBIDN_CFLAGS');
	MkExecPkgConfig($pfx, 'libidn2', '--libs', 'LIBIDN_LIBS');
	MkIfFound($pfx, $ver, 'LIBIDN_VERSION');
		MkPrintSN('checking whether libidn2 works...');
		MkCompileC('HAVE_LIBIDN', '${LIBIDN_CFLAGS}', '${LIBIDN_LIBS}', $testCode);
		MkIfFalse('${HAVE_LIBIDN}');
			MkDisableFailed('libidn');
		MkEndif;
	MkElse;
		MkDisableNotFound('libidn');
	MkEndif;
}

sub DISABLE_libidn
{
	MkDefine('HAVE_LIBIDN', 'no') unless $TestFailed;
	MkDefine('LIBIDN_CFLAGS', '');
	MkDefine('LIBIDN_LIBS', '');
	MkSaveUndef('HAVE_LIBIDN');
}

BEGIN
{
	my $n = 'libidn';

	$DESCR{$n}   = 'libidn2';
	$URL{$n}     = 'http://www.gnu.org/software/libidn';
	$TESTS{$n}   = \&TEST_libidn;
	$DISABLE{$n} = \&DISABLE_libidn;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'LIBIDN_CFLAGS LIBIDN_LIBS';
}
;1
