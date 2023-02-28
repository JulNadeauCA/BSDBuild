# Public domain

sub TEST_mprotect
{
	TryCompile 'HAVE_MPROTECT', << 'EOF';
#include <sys/mman.h>

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	void *p;
	int psz;
	char *buffer;

	psz = sysconf(_SC_PAGE_SIZE);
	if (psz == -1) {
		return (1);
	}

	posix_memalign(&buffer, psz, psz*4);
	if (buffer == NULL)
		return (1);

	mprotect(buffer + psz*2, psz, PROT_READ);
	return (0);
}
EOF
}

sub DISABLE_mprotect
{
	MkDefine('HAVE_MPROTECT', 'no');
	MkSaveUndef('HAVE_MPROTECT');
}

BEGIN
{
	my $n = 'mprotect';

	$DESCR{$n}   = 'mprotect()';
	$TESTS{$n}   = \&TEST_mprotect;
	$DISABLE{$n} = \&DISABLE_mprotect;
	$DEPS{$n}    = 'cc';
}
;1
