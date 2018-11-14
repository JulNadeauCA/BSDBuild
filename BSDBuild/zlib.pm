# Public domain
# vim:ts=4

my @autoPrefixDirs = (
	'/usr/local',
	'/usr'
);

sub Test
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
		Disable();
		MkPrintS('no');
	MkEndif;
	return (0);
}

sub Disable
{
	MkDefine('HAVE_ZLIB', 'no');
	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');
	MkSaveUndef('HAVE_ZLIB', 'ZLIB_CFLAGS', 'ZLIB_LIBS');
}

sub Emul
{
	MkEmulUnavail('ZLIB');
	return (1);
}

BEGIN
{
	my $n = 'zlib';

	$DESCR{$n} = 'zlib';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}

;1
