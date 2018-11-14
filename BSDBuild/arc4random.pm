# Public domain
# vim:ts=4

sub Test_Arc4random
{
	TryCompile 'HAVE_ARC4RANDOM', << 'EOF';
#include <sys/types.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
	u_int32_t i = arc4random();
	return (0);
}
EOF
}

sub Disable_Arc4random
{
	MkDefine('HAVE_ARC4RANDOM', 'no');
	MkSaveUndef('HAVE_ARC4RANDOM');
}

sub Emul
{
	MkEmulUnavailSYS('ARC4RANDOM');
	return (1);
}

BEGIN
{
	my $n = 'arc4random';

	$DESCR{$n} = 'arc4random()';

	$TESTS{$n}   = \&Test_Arc4random;
	$DISABLE{$n} = \&Disable_Arc4random;
	$EMUL{$n}    = \&Emul;
	
	$DEPS{$n} = 'cc';
}

;1
