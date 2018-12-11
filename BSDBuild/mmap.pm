# vim:ts=4
# Public domain

sub TEST_mmap
{
	TryCompile 'HAVE_MMAP', << 'EOF';
#include <sys/types.h>
#include <sys/mman.h>

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	void *p;

	p = mmap(NULL, (size_t)0, (int)0, (int)0, (int)0, (off_t)0);
	munmap(NULL, (size_t)0);
	return (0);
}
EOF
}

sub DISABLE_mmap
{
	MkDefine('HAVE_MMAP', 'no');
	MkSaveUndef('HAVE_MMAP');
}

BEGIN
{
	my $n = 'mmap';

	$DESCR{$n}   = 'mmap()';
	$TESTS{$n}   = \&TEST_mmap;
	$DISABLE{$n} = \&DISABLE_mmap;
	$DEPS{$n}    = 'cc';
}
;1
