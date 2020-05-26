# Public domain

sub TEST_getpeerucred
{
	TryCompile 'HAVE_GETPEERUCRED', << 'EOF';
#include <ucred.h>

int
main(int argc, char *argv[])
{
	int rv, fd = 0;
	size_t size;
	ucred_t *creds;
	uid_t uid;
	gid_t gid;

	size = ucred_size();
	rv = getpeerucred(fd, &creds);
	if (rv != 0) { return (1); }
	uid = ucred_getruid(creds);
	gid = ucred_getrgid(creds);
	ucred_free(creds);
	return (0);
}
EOF
}

sub DISABLE_getpeerucred
{
	MkDefine('HAVE_GETPEERUCRED', 'no');
	MkSaveUndef('HAVE_GETPEERUCRED');
}

BEGIN
{
	my $n = 'getpeerucred';

	$DESCR{$n}   = 'the getpeerucred() interface';
	$TESTS{$n}   = \&TEST_getpeerucred;
	$DISABLE{$n} = \&DISABLE_getpeerucred;
	$DEPS{$n}    = 'cc';
}
;1
