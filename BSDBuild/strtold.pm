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

sub CMAKE_strtold
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Strtold)
	check_c_source_compiles("
$code" _MK_HAVE_STRTOLD)
	if (_MK_HAVE_STRTOLD)
		BB_Save_Define(_MK_HAVE_STRTOLD)
	else()
		BB_Save_Undef(_MK_HAVE_STRTOLD)
	endif()
endmacro()
EOF
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
	$CMAKE{$n}   = \&CMAKE_strtold;
	$DISABLE{$n} = \&DISABLE_strtold;
	$DEPS{$n}    = 'cc';
}
;1
