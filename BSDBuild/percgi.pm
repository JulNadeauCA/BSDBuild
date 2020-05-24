# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <libpercgi/cgi.h>

int
main(int argc, char *argv[])
{
	CGI_Init(NULL);
	return (0);
}
EOF

sub TEST_percgi
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'percgi-config', '--version', 'PERCGI_VERSION');
	MkIfFound($pfx, $ver, 'PERCGI_VERSION');
		MkExecOutputPfx($pfx, 'percgi-config', '--cflags', 'PERCGI_CFLAGS');
		MkExecOutputPfx($pfx, 'percgi-config', '--libs', 'PERCGI_LIBS');
		MkPrintSN('checking whether PerCGI works...');
		MkCompileC('HAVE_PERCGI', '${PERCGI_CFLAGS}', '${PERCGI_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_PERCGI}', 'PERCGI_CFLAGS', 'PERCGI_LIBS');
	MkElse;
		DISABLE_percgi();
	MkEndif;
}

sub DISABLE_percgi
{
	MkDefine('HAVE_PERCGI', 'no');
	MkDefine('PERCGI_CFLAGS', '');
	MkDefine('PERCGI_LIBS', '');
	MkSaveUndef('HAVE_PERCGI');
}

BEGIN
{
	my $n = 'percgi';

	$DESCR{$n}   = 'PerCGI';
	$URL{$n}     = 'http://percgi.hypertriton.com';
	$TESTS{$n}   = \&TEST_percgi;
	$DISABLE{$n} = \&DISABLE_percgi;
	$DEPS{$n}    = 'cc';
}
;1
