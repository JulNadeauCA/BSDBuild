# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdarg.h>

static void
testfmt(const char *fmt, ...)
{
	char buf[16];
	va_list ap;
	va_start(ap, fmt);
	(void)vsnprintf(buf, sizeof(buf), fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	testfmt("foo", 1, 2, 3);
	return (0);
}
EOF

sub TEST_vsnprintf
{
	TryCompile('HAVE_VSNPRINTF', $testCode);
}

sub CMAKE_vsnprintf
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Vsnprintf)
	check_c_source_compiles("
$code" HAVE_VSNPRINTF)
	if (HAVE_VSNPRINTF)
		BB_Save_Define(HAVE_VSNPRINTF)
	else()
		BB_Save_Undef(HAVE_VSNPRINTF)
	endif()
endmacro()
EOF
}

sub DISABLE_vsnprintf
{
	MkDefine('HAVE_VSNPRINTF', 'no');
	MkSaveUndef('HAVE_VSNPRINTF');
}

BEGIN
{
	my $n = 'vsnprintf';

	$DESCR{$n}   = 'vsnprintf()';
	$TESTS{$n}   = \&TEST_vsnprintf;
	$CMAKE{$n}   = \&CMAKE_vsnprintf;
	$DISABLE{$n} = \&DISABLE_vsnprintf;
	$DEPS{$n}    = 'cc';
}
;1
