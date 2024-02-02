# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdarg.h>

int
testprintf(const char *fmt, ...)
{
	va_list args;
	char *buf;

	va_start(args, fmt);
	if (vasprintf(&buf, "%s", args) == -1) {
		return (-1);
	}
	va_end(args);
	return (0);
}
int
main(int argc, char *argv[])
{
	return (testprintf("foo %s", "bar"));
}
EOF

sub TEST_vasprintf
{
	TryCompileFlagsC('HAVE_VASPRINTF', '-D_GNU_SOURCE', $testCode);
}

sub CMAKE_vasprintf
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Vasprintf)
	check_c_source_compiles("
$code" HAVE_VASPRINTF)
	if (HAVE_VASPRINTF)
		BB_Save_Define(HAVE_VASPRINTF)
	else()
		BB_Save_Undef(HAVE_VASPRINTF)
	endif()
endmacro()
EOF
}

sub DISABLE_vasprintf
{
	MkDefine('HAVE_VASPRINTF', 'no');
	MkSaveUndef('HAVE_VASPRINTF');
}

BEGIN
{
	my $n = 'vasprintf';

	$DESCR{$n}   = 'vasprintf()';
	$TESTS{$n}   = \&TEST_vasprintf;
	$CMAKE{$n}   = \&CMAKE_vasprintf;
	$DISABLE{$n} = \&DISABLE_vasprintf;
	$DEPS{$n}    = 'cc';
}
;1
