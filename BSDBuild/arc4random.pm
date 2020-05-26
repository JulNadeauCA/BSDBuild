# Public domain

sub TEST_arc4random
{
	TryCompile 'HAVE_ARC4RANDOM', << 'EOF';
#include <sys/types.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
	u_int32_t i = arc4random();
	return (i != 0);
}
EOF
}

sub DISABLE_arc4random
{
	MkDefine('HAVE_ARC4RANDOM', 'no');
	MkSaveUndef('HAVE_ARC4RANDOM');
}

BEGIN
{
	my $n = 'arc4random';

	$DESCR{$n}   = 'arc4random()';
	$TESTS{$n}   = \&TEST_arc4random;
	$DISABLE{$n} = \&DISABLE_arc4random;
	$DEPS{$n}    = 'cc';
}
;1
