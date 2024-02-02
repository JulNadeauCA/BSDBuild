# Public domain

my $testCode = << 'EOF';
#include <signal.h>

void sighandler(int sig) { }
int
main(int argc, char *argv[])
{
	signal(SIGTERM, sighandler);
	signal(SIGILL, sighandler);
	return (0);
}
EOF

sub TEST_signal
{
	TryCompile('_MK_HAVE_SIGNAL', $testCode);
}

sub CMAKE_signal
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Signal)
	check_c_source_compiles("
$code" _MK_HAVE_SIGNAL)
	if (_MK_HAVE_SIGNAL)
		BB_Save_Define(_MK_HAVE_SIGNAL)
	else()
		BB_Save_Undef(_MK_HAVE_SIGNAL)
	endif()
endmacro()
EOF
}

sub DISABLE_signal
{
	MkDefine('_MK_HAVE_SIGNAL', 'no');
	MkSaveUndef('_MK_HAVE_SIGNAL');
}

BEGIN
{
	my $n = 'signal';

	$DESCR{$n}   = 'ANSI-style signal() facilities';
	$TESTS{$n}   = \&TEST_signal;
	$CMAKE{$n}   = \&CMAKE_signal;
	$DISABLE{$n} = \&DISABLE_signal;
	$DEPS{$n}    = 'cc';
}
;1
