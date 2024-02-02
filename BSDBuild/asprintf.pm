# Public domain

my $testCode = << 'EOF';
#include <stdio.h>

int
main(int argc, char *argv[])
{
	char *buf;
	if (asprintf(&buf, "foo %s", "bar") == 0) {
	    return (0);
	}
	return (1);
}
EOF

sub TEST_asprintf
{
	TryCompileFlagsC('HAVE_ASPRINTF', '-D_GNU_SOURCE', $testCode);
}

sub CMAKE_asprintf
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Asprintf)
	check_c_source_compiles("
$code" HAVE_ASPRINTF)
	if (HAVE_ASPRINTF)
		BB_Save_Define(HAVE_ASPRINTF)
	else()
		BB_Save_Undef(HAVE_ASPRINTF)
	endif()
endmacro()
EOF
}

sub DISABLE_asprintf
{
	MkDefine('HAVE_ASPRINTF', 'no');
	MkSaveUndef('HAVE_ASPRINTF');
}

BEGIN
{
	my $n = 'asprintf';

	$DESCR{$n}   = 'asprintf()';
	$TESTS{$n}   = \&TEST_asprintf;
	$CMAKE{$n}   = \&CMAKE_asprintf;
	$DISABLE{$n} = \&DISABLE_asprintf;
	$DEPS{$n}    = 'cc';
}
;1
