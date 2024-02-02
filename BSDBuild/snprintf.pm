# Public domain

my $testCode = << 'EOF';
#include <stdio.h>

int main(int argc, char *argv[])
{
	char buf[16];
	(void)snprintf(buf, sizeof(buf), "foo");
	return (0);
}
EOF

sub TEST_snprintf
{
	TryCompile('HAVE_SNPRINTF', $testCode);
}

sub CMAKE_snprintf
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Snprintf)
	check_c_source_compiles("
$code" HAVE_SNPRINTF)
	if (HAVE_SNPRINTF)
		BB_Save_Define(HAVE_SNPRINTF)
	else()
		BB_Save_Undef(HAVE_SNPRINTF)
	endif()
endmacro()
EOF
}

sub DISABLE_snprintf
{
	MkDefine('HAVE_SNPRINTF', 'no');
	MkSaveUndef('HAVE_SNPRINTF');
}

BEGIN
{
	my $n = 'snprintf';

	$DESCR{$n}   = 'snprintf()';
	$TESTS{$n}   = \&TEST_snprintf;
	$CMAKE{$n}   = \&CMAKE_snprintf;
	$DISABLE{$n} = \&DISABLE_snprintf;
	$DEPS{$n}    = 'cc';
}
;1
