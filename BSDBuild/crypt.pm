# Public domain

my $testCode = << 'EOF';
#include <unistd.h>

int
main(int argc, char *argv[])
{
	char *key = "some key", *salt = "sa";
	char *enc;

	if ((enc = crypt(key, salt)) != NULL) {
		return (1);
	}
	return (0);
}
EOF

sub TEST_crypt
{
	MkDefine('CRYPT_CFLAGS', '');
	MkDefine('CRYPT_LIBS', '');

	TryCompileFlagsC('HAVE_CRYPT', '-lcrypt', $testCode);
	MkIfTrue('${HAVE_CRYPT}');
		MkDefine('CRYPT_CFLAGS', '');
		MkDefine('CRYPT_LIBS', '-lcrypt');
	MkElse;
		MkPrintSN('checking for crypt() in libc...');
		TryCompileFlagsC('HAVE_CRYPT', '', $testCode);
		MkIfTrue('${HAVE_CRYPT}');
			MkDefine('CRYPT_CFLAGS', '');
			MkDefine('CRYPT_LIBS', '');
		MkElse;
			MkDisableFailed('crypt');
		MkEndif;
	MkEndif;
}

sub DISABLE_crypt
{
	MkDefine('HAVE_CRYPT', 'no') unless $TestFailed;
	MkDefine('CRYPT_CFLAGS', '');
	MkDefine('CRYPT_LIBS', '');
	MkSaveUndef('HAVE_CRYPT');
}

BEGIN
{
	my $n = 'crypt';

	$DESCR{$n}   = 'the crypt() routine (in -lcrypt)';
	$TESTS{$n}   = \&TEST_crypt;
	$DISABLE{$n} = \&DISABLE_crypt;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CRYPT_CFLAGS CRYPT_LIBS';
}
;1
