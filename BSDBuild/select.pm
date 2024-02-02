# Public domain

my $testCode = << 'EOF';
#include <sys/types.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

int
main(int argc, char *argv[])
{
	struct timeval tv;
	int rv;

	tv.tv_sec = 1;
	tv.tv_usec = 1;
	rv = select(0, NULL, NULL, NULL, &tv);
	return (rv == -1 && errno != EINTR);
}
EOF

sub TEST_select
{
	TryCompile('HAVE_SELECT', $testCode);
}

sub CMAKE_select
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Select)
	check_c_source_compiles("
$code" HAVE_SELECT)
	if (HAVE_SELECT)
		BB_Save_Define(HAVE_SELECT)
	else()
		BB_Save_Undef(HAVE_SELECT)
	endif()
endmacro()
EOF
}

sub DISABLE_select
{
	MkDefine('HAVE_SELECT', 'no');
	MkSaveUndef('HAVE_SELECT');
}

BEGIN
{
	my $n = 'select';

	$DESCR{$n}   = 'the select() interface';
	$TESTS{$n}   = \&TEST_select;
	$CMAKE{$n}   = \&CMAKE_select;
	$DISABLE{$n} = \&DISABLE_select;
	$DEPS{$n}    = 'cc';
}
;1
