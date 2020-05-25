# Public domain
# vim:ts=4

my @autoPrefixDirs = (
	'/usr',
	'/usr/local',
	'/opt',
	'/opt/local',
	'/usr/pkg'
);

my $testCode = << "EOF";
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <iconv.h>

int main(int argc, char *argv[])
{
	char *inbuf = "foo";
	size_t inlen = strlen(inbuf), rv;
	char *outbuf = malloc(3);
	size_t outbuflen = 3;
	iconv_t cd;

	cd = iconv_open("ISO-8859-1", "UTF-8");
	rv = iconv(cd, &inbuf, &inlen, &outbuf, &outbuflen);
	iconv_close(cd);
	return ((rv == (size_t)-1));
}
EOF

sub TEST_iconv
{
	my ($ver, $pfx) = @_;

	MkDefine('ICONV_CFLAGS', '');
	MkDefine('ICONV_LIBS', '');
	
	MkIfNE($pfx, '');
		MkIfExists("$pfx/include/iconv.h");
		    MkDefine('ICONV_CFLAGS', "-I$pfx/include");
		    MkDefine('ICONV_LIBS', "-L$pfx/lib -liconv");
		MkEndif;
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIfExists("$dir/include/iconv.h");
			    MkDefine('ICONV_CFLAGS', "-I$dir/include");
			    MkDefine('ICONV_LIBS', "-L$dir/lib -liconv");
			MkEndif;
		}
	MkEndif;
	MkCompileC('HAVE_ICONV', '${ICONV_CFLAGS} -Wno-cast-qual',
	           '${ICONV_LIBS}', $testCode);

	MkSave('ICONV_CFLAGS', 'ICONV_LIBS');
}

sub DISABLE_iconv
{
	MkDefine('HAVE_ICONV', 'no');
	MkDefine('ICONV_CFLAGS', '');
	MkDefine('ICONV_LIBS', '');
	MkSaveUndef('HAVE_ICONV');
}

BEGIN
{
	my $n = 'iconv';

	$DESCR{$n}   = 'iconv()';
	$TESTS{$n}   = \&TEST_iconv;
	$DISABLE{$n} = \&DISABLE_iconv;
	$DEPS{$n}    = 'cc';
}
;1
