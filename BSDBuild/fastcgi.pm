# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <fcgi_stdio.h>

int
main(int argc, char *argv[])
{
	printf("foo\n");
	return (0);
}
EOF

my @autoPrefixes = (
	'/usr/local',
	'/usr',
	'/opt/local',
	'/opt',
);

sub TEST_fastcgi
{
	my ($ver, $pfx) = @_;

	MkDefine('FASTCGI_CFLAGS', '');
	MkDefine('FASTCGI_LIBS', '');

	MkIfNE($pfx, '');
			MkIfExists("$pfx/include/fcgi_stdio.h");
				MkDefine('FASTCGI_CFLAGS', "-I$pfx/include");
			    MkDefine('FASTCGI_LIBS', "-L$pfx/lib -lfcgi");
			MkEndif;
	MkElse;
		foreach my $dir (@autoPrefixes) {
			MkIfExists("$dir/include/fcgi_stdio.h");
				MkDefine('FASTCGI_CFLAGS', "-I$dir/include");
			    MkDefine('FASTCGI_LIBS', "-L$dir/lib -lfcgi");
			MkEndif;
		}
	MkEndif;

	MkIfNE('${FASTCGI_LIBS}', '');
		MkPrintS('yes');
		MkPrintSN('checking whether fastcgi works...');
		MkCompileC('HAVE_FASTCGI', '${FASTCGI_CFLAGS}', '${FASTCGI_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_FASTCGI}', 'FASTCGI_CFLAGS', 'FASTCGI_LIBS');
	MkElse;
		MkPrintS('no');
		DISABLE_fastcgi();
	MkEndif;
}

sub DISABLE_fastcgi
{
	MkDefine('HAVE_FASTCGI', 'no');
	MkDefine('FASTCGI_CFLAGS', '');
	MkDefine('FASTCGI_LIBS', '');
	MkSaveUndef('HAVE_FASTCGI');
}

BEGIN
{
	my $n = 'fastcgi';

	$DESCR{$n}   = 'FastCGI (http://fastcgi.com)';
	$URL{$n}     = 'http://fastcgi.com';
	$TESTS{$n}   = \&TEST_fastcgi;
	$DISABLE{$n} = \&DISABLE_fastcgi;
	$DEPS{$n}    = 'cc';
}
;1
