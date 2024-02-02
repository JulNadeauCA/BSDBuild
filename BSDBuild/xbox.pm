# Public domain

my $testCode = << 'EOF';
#include <xtl.h>
#ifndef _XBOX
# error undefined
#endif

int
main(int argc, char *argv[])
{
	return (0);
}
EOF

sub TEST_xbox
{
	TryCompile('HAVE_XBOX', $testCode);
}

sub CMAKE_xbox
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Xbox)
	check_c_source_compiles("
$code" HAVE_XBOX)
	if (HAVE_XBOX)
		BB_Save_Define(HAVE_XBOX)
	else()
		BB_Save_Undef(HAVE_XBOX)
	endif()
endmacro()

macro(Disable_Xbox)
	set(HAVE_XBOX OFF)
	BB_Save_Undef(HAVE_XBOX)
endmacro()
EOF
}

sub DISABLE_xbox
{
	MkDefine('HAVE_XBOX', 'no');
	MkSaveUndef('HAVE_XBOX');
}

BEGIN
{
	my $n = 'xbox';

	$DESCR{$n}   = 'the Xbox XDK';
	$TESTS{$n}   = \&TEST_xbox;
	$CMAKE{$n}   = \&CMAKE_xbox;
	$DISABLE{$n} = \&DISABLE_xbox;
	$DEPS{$n}    = 'cc';
}
;1
