# Public domain

my $testCode = << 'EOF';
#include <sys/types.h>
#include <unistd.h>
int main(int argc, char *argv[]) {
	char buf;
	int rv, fdout=1;

	if ((rv = write(fdout, (void *)&buf, 1)) < 1) { return (1); }
	if ((rv = read(0, (void *)&buf, 1)) < 1) { return (1); }
	if (unlink("/tmp/foo") != 0) { return (1); }
	return (0);
}
EOF

sub TEST_unistd_h
{
	MkCompileC('_MK_HAVE_UNISTD_H', '', '', $testCode);
}

sub CMAKE_unistd_h
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Unistd_h)
	check_c_source_compiles("
$code" _MK_HAVE_UNISTD_H)
	if (_MK_HAVE_UNISTD_H)
		BB_Save_Define(_MK_HAVE_UNISTD_H)
	else()
		BB_Save_Undef(_MK_HAVE_UNISTD_H)
	endif()
endmacro()
EOF
}

sub DISABLE_unistd_h
{
	MkDefine('_MK_HAVE_UNISTD_H', 'no');
	MkSaveUndef('_MK_HAVE_UNISTD_H');
}

BEGIN
{
	my $n = 'unistd_h';

	$DESCR{$n}   = '<unistd.h>';
	$TESTS{$n}   = \&TEST_unistd_h;
	$CMAKE{$n}   = \&CMAKE_unistd_h;
	$DISABLE{$n} = \&DISABLE_unistd_h;
	$DEPS{$n}    = 'cc';
}
;1
