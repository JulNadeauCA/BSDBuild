# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stringprep.h>
#include <idna.h>

int main(int argc, char *argv[]) {
	char *buf = "foo.com", *p;
	int rv;
	rv = idna_to_unicode_lzlz(buf, &p, 0);
	return ((rv == IDNA_SUCCESS) ? 0 : 1);
}
EOF

sub TEST_libidn
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'libidn', '--modversion', 'LIBIDN_VERSION');
	MkExecPkgConfig($pfx, 'libidn', '--cflags', 'LIBIDN_CFLAGS');
	MkExecPkgConfig($pfx, 'libidn', '--libs', 'LIBIDN_LIBS');
	MkIfFound($pfx, $ver, 'LIBIDN_VERSION');
		MkPrintSN('checking whether libidn works...');
		MkCompileC('HAVE_LIBIDN', '${LIBIDN_CFLAGS}', '${LIBIDN_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_LIBIDN}', 'LIBIDN_CFLAGS', 'LIBIDN_LIBS');
	MkElse;
		MkSaveUndef('HAVE_LIBIDN');
	MkEndif;
}

sub DISABLE_libidn
{
	MkDefine('HAVE_LIBIDN', 'no');
	MkDefine('LIBIDN_CFLAGS', '');
	MkDefine('LIBIDN_LIBS', '');
	MkSaveUndef('HAVE_LIBIDN');
}

BEGIN
{
	my $n = 'libidn';

	$DESCR{$n}   = 'libidn';
	$URL{$n}     = 'http://www.gnu.org/software/libidn';
	$TESTS{$n}   = \&TEST_libidn;
	$DISABLE{$n} = \&DISABLE_libidn;
	$DEPS{$n}    = 'cc';
}
;1
