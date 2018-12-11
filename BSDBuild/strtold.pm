# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#ifndef __NetBSD__
# define _XOPEN_SOURCE 600
#endif
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	long double ld;
	char *ep = NULL;
	char *foo = "1234";

	ld = strtold(foo, &ep);
	return (ld != 1234.0);
}
EOF

sub TEST_strtold
{
	MkIfTrue('${HAVE_LONG_DOUBLE}');
		MkIfFalse('${HAVE_CYGWIN}');
			TryCompile('_MK_HAVE_STRTOLD', $testCode);
		MkElse;
			MkDefine('_MK_HAVE_STRTOLD', 'no');
			MkSaveUndef('_MK_HAVE_STRTOLD');
			MkPrintS('not checking (cygwin issues)');
		MkEndif;
	MkElse;
		MkDefine('_MK_HAVE_STRTOLD', 'no');
		MkSaveUndef('_MK_HAVE_STRTOLD');
		MkPrintS('skipping (no long double)');
	MkEndif;
}

sub DISABLE_strtold
{
	MkDefine('_MK_HAVE_STRTOLD', 'no');
	MkSaveUndef('_MK_HAVE_STRTOLD');
}

BEGIN
{
	my $n = 'strtold';

	$DESCR{$n}   = 'strtold()';
	$TESTS{$n}   = \&TEST_strtold;
	$DISABLE{$n} = \&DISABLE_strtold;
	$DEPS{$n}    = 'cc';
}
;1
