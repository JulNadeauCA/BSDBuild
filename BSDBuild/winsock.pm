# Public domain

sub TEST_winsock
{
	MkPrintS("not checking");
	MkDisableNotFound('winsock');
}

sub DISABLE_winsock
{
	MkDefine('HAVE_WINSOCK1', 'no');
	MkDefine('HAVE_WINSOCK2', 'no');
	MkSaveUndef('HAVE_WINSOCK1', 'HAVE_WINSOCK2');
}

sub CMAKE_winsock
{
	return << 'EOF';
macro(Check_Winsock)
	if(WINDOWS)
		BB_Save_Define(HAVE_WINSOCK1)
		BB_Save_Define(HAVE_WINSOCK2)
	else()
		BB_Save_Undef(HAVE_WINSOCK1)
		BB_Save_Undef(HAVE_WINSOCK2)
	endif()
endmacro()

macro(Disable_Winsock)
	BB_Save_Undef(HAVE_WINSOCK1)
	BB_Save_Undef(HAVE_WINSOCK2)
endmacro()
EOF
}

BEGIN
{
	my $n = 'winsock';

	$DESCR{$n}   = 'WinSock';
	$TESTS{$n}   = \&TEST_winsock;
	$CMAKE{$n}   = \&CMAKE_winsock;
	$DISABLE{$n} = \&DISABLE_winsock;
}
;1
