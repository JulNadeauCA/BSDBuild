# Public domain

my $testCode = << 'EOF';
#include <stdlib.h>
int main(int argc, char *argv[]) {
	void *foo = malloc(1);
	free(foo);
	return (0);
}
EOF

sub TEST_stdlib_h
{
	MkCompileC('_MK_HAVE_STDLIB_H', '', '', $testCode);
}

sub CMAKE_stdlib_h
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Stdlib_h)
	check_c_source_compiles("
$code" _MK_HAVE_STDLIB_H)
	if (_MK_HAVE_STDLIB_H)
		BB_Save_Define(_MK_HAVE_STDLIB_H)
	else()
		BB_Save_Undef(_MK_HAVE_STDLIB_H)
	endif()
endmacro()
EOF
}

sub DISABLE_stdlib_h
{
	MkDefine('_MK_HAVE_STDLIB_H', 'no');
	MkSaveUndef('_MK_HAVE_STDLIB_H');
}

BEGIN
{
	my $n = 'stdlib_h';

	$DESCR{$n}   = '<stdlib.h>';
	$TESTS{$n}   = \&TEST_stdlib_h;
	$CMAKE{$n}   = \&CMAKE_stdlib_h;
	$DISABLE{$n} = \&DISABLE_stdlib_h;
	$DEPS{$n}    = 'cc';
}
;1
