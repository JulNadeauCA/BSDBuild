# Public domain

sub TEST_getpwnam_r
{
	TryCompile 'HAVE_GETPWNAM_R', << 'EOF';
#include <sys/types.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

int
main(int argc, char *argv[])
{
	struct passwd pw, *res;
	char *buf;
	size_t bufSize;
	int rv;

	bufSize = sysconf(_SC_GETPW_R_SIZE_MAX);
	if (bufSize == -1) { bufSize = 16384; }
	if ((buf = malloc(bufSize)) == NULL) { return (1); }

	rv = getpwnam_r("foo", &pw, buf, bufSize, &res);
	if (res == NULL) {
		return (rv == 0);
	}
	return (pw.pw_dir != NULL);
}
EOF
}

sub DISABLE_getpwnam_r
{
	MkDefine('HAVE_GETPWNAM_R', 'no');
	MkSaveUndef('HAVE_GETPWNAM_R');
}

BEGIN
{
	my $n = 'getpwnam_r';

	$DESCR{$n}   = 'the getpwnam_r() interface';
	$TESTS{$n}   = \&TEST_getpwnam_r;
	$DISABLE{$n} = \&DISABLE_getpwnam_r;
	$DEPS{$n}    = 'cc';
}
;1
