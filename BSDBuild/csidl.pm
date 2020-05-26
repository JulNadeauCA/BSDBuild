# Public domain

my $testCode = << 'EOF';
#include <shlobj.h>

int
main(int argc, char *argv[])
{
	WCHAR path[MAX_PATH];

	if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_PROFILE, NULL, 0, path))) {
		return (0);
	} else {
		return (1);
	}
}
EOF

sub TEST_csidl
{
	MkCompileC('HAVE_CSIDL', '', '', $testCode);
}

sub DISABLE_csidl
{
	MkDefine('HAVE_CSIDL', 'no');
	MkSaveUndef('HAVE_CSIDL');
}

BEGIN
{
	my $n = 'csidl';

	$DESCR{$n}   = 'Windows CSIDL';
	$TESTS{$n}   = \&TEST_csidl;
	$DISABLE{$n} = \&DISABLE_csidl;
	$DEPS{$n}    = 'cc';
}
;1
