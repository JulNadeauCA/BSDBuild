# Public domain

sub TEST_math
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkDefine('MATH_CFLAGS', "-I$pfx");
		MkDefine('MATH_LIBS', "-L$pfx -lm");
	MkElse;
		MkDefine('MATH_CFLAGS', '');
		MkDefine('MATH_LIBS', '-lm');
	MkEndif;

	MkCompileC('HAVE_MATH', '${CFLAGS} ${MATH_CFLAGS}', '${MATH_LIBS}', << 'EOF');
#include <math.h>

int
main(int argc, char *argv[])
{
	double d = 1.0;
	d = fabs(d);
	return (0);
}
EOF
}

sub DISABLE_math
{
	MkDefine('HAVE_MATH', 'no');
	MkDefine('MATH_CFLAGS', '');
	MkDefine('MATH_LIBS', '');
	MkSaveUndef('HAVE_MATH');
}

sub EMUL_math
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('MATH', '');
	} else {
		MkEmulUnavail('MATH');
	}
	return (1);
}

BEGIN
{
	my $n = 'math';

	$DESCR{$n}   = 'the C math library';
	$TESTS{$n}   = \&TEST_math;
	$DISABLE{$n} = \&DISABLE_math;
	$EMUL{$n}    = \&EMUL_math;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MATH_CFLAGS MATH_LIBS';
}
;1
