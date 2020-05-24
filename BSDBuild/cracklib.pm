# Public domain
# vim:ts=4

my @autoPrefixDirs = (
	'/usr/local',
	'/usr'
);
my @dictPaths = (
	'/usr/local/libdata/cracklib/pw_dict',
	'/usr/local/share/cracklib/cracklib-small',
);

sub TEST_cracklib
{
	my ($ver, $pfx) = @_;

	MkDefine('CRACKLIB_CFLAGS', '');
	MkDefine('CRACKLIB_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('CRACKLIB_CFLAGS', "-I$pfx/include");
		MkDefine('CRACKLIB_LIBS', "-L$pfx/lib -lcrack");
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIf("-f \"$dir/include/packer.h\"");
				MkDefine('CRACKLIB_CFLAGS', "-I$dir/include");
				MkDefine('CRACKLIB_LIBS', "-L$dir/lib -lcrack");
			MkEndif;
		}
	MkEndif;
		
	MkIfNE('${CRACKLIB_LIBS}', '');
		MkPrintS('ok');
		MkPrintSN('checking whether cracklib works...');
		MkCompileC('HAVE_CRACKLIB', '${CRACKLIB_CFLAGS}', '${CRACKLIB_LIBS}',
		    << 'EOF');
#include <stdio.h>
#include <packer.h>
int main(int argc, char *argv[]) {
	const char *msg = (const char *)FascistCheck("foobar", "/path");
	return (msg != NULL);
}
EOF
		MkSaveIfTrue('${HAVE_CRACKLIB}', 'CRACKLIB_CFLAGS', 'CRACKLIB_LIBS');
		MkIfTrue('${HAVE_CRACKLIB}', '');
			foreach my $path (@dictPaths) {
				MkIf("-f \"$path.pwd\"");
					MkDefine('CRACKLIB_DICT_PATH', "$path");
					MkSaveDefine('CRACKLIB_DICT_PATH');
				MkEndif;
			}
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_CRACKLIB');
		MkPrintS('no');
	MkEndif;
}

sub DISABLE_cracklib
{
	MkDefine('HAVE_CRACKLIB', 'no');
	MkDefine('CRACKLIB_CFLAGS', '');
	MkDefine('CRACKLIB_LIBS', '');
	MkDefine('CRACKLIB_DICT_PATH', '');
	MkSaveUndef('HAVE_CRACKLIB', 'CRACKLIB_DICT_PATH');
}

BEGIN
{
	my $n = 'cracklib';

	$DESCR{$n}   = 'cracklib';
	$TESTS{$n}   = \&TEST_cracklib;
	$DISABLE{$n} = \&DISABLE_cracklib;
	$DEPS{$n}    = 'cc';
}
;1
