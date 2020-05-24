# vim:ts=4
# Public domain

my @autoPrefixDirs = (
	'/usr/local',
	'/usr'
);

sub TEST_zlib
{
	my ($ver, $pfx) = @_;

	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('ZLIB_CFLAGS', "-I$pfx/include");
		MkDefine('ZLIB_LIBS', "-L$pfx/lib -lz");
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIf("-f \"$dir/include/zlib.h\"");
				MkDefine('ZLIB_CFLAGS', "-I$dir/include");
				MkDefine('ZLIB_LIBS', "-L$dir/lib -lz");
			MkEndif;
		}
	MkEndif;
		
	MkIfNE('${ZLIB_LIBS}', '');
		MkPrintS('ok');
		MkPrintSN('checking whether zlib works...');
		MkCompileC('HAVE_ZLIB', '${ZLIB_CFLAGS}', '${ZLIB_LIBS}',
		    << 'EOF');
#include <stdio.h>
#include <string.h>
#include <zlib.h>

int main(int argc, char *argv[]) {
	z_stream strm;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	return deflateInit(&strm, 0);
}
EOF
		MkSaveIfTrue('${HAVE_ZLIB}', 'ZLIB_CFLAGS', 'ZLIB_LIBS');
	MkElse;
		MkPrintS('no');
		DISABLE_zlib();
	MkEndif;
}

sub DISABLE_zlib
{
	MkDefine('HAVE_ZLIB', 'no');
	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');
	MkSaveUndef('HAVE_ZLIB');
}

BEGIN
{
	my $n = 'zlib';

	$DESCR{$n}   = 'zlib';
	$TESTS{$n}   = \&TEST_zlib;
	$DISABLE{$n} = \&DISABLE_zlib;
	$DEPS{$n}    = 'cc';
}
;1
