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

sub CMAKE_csidl
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Csidl)
	check_c_source_compiles("
$code" HAVE_CSIDL)
	if (HAVE_CSIDL)
		BB_Save_Define(HAVE_CSIDL)
	else()
		BB_Save_Undef(HAVE_CSIDL)
	endif()
endmacro()
EOF
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
	$CMAKE{$n}   = \&CMAKE_csidl;
	$DISABLE{$n} = \&DISABLE_csidl;
	$DEPS{$n}    = 'cc';
}
;1
