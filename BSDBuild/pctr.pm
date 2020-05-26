# Public domain

sub TEST_pctr
{
	TryCompile 'HAVE_PCTR', << 'EOF';
#include <sys/types.h>
#include <stdio.h>
#include <machine/pctr.h>
int
main(int argc, char *argv[])
{
	pctrval v = rdtsc();
	return (rdtsc() == v);
}
EOF
}

sub DISABLE_pctr
{
	MkDefine('HAVE_PCTR', 'no');
	MkSaveUndef('HAVE_PCTR');
}

BEGIN
{
	my $n = 'pctr';

	$DESCR{$n}   = 'the pctr(4) interface';
	$TESTS{$n}   = \&TEST_pctr;
	$DISABLE{$n} = \&DISABLE_pctr;
	$DEPS{$n}    = 'cc';
}
;1
