# vim:ts=4
# Public domain

sub TEST_winsock
{
	MkPrintS("not checking");
	DISABLE_winsock();
}

sub DISABLE_winsock
{
	MkDefine('HAVE_WINSOCK1', 'no');
	MkDefine('HAVE_WINSOCK2', 'no');
	MkSaveUndef('HAVE_WINSOCK1', 'HAVE_WINSOCK2');
}

sub EMUL_winsock
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /windows-(xp|vista|7)/) {
		MkEmulWindows('WINSOCK1', 'wsock32');
		MkEmulWindows('WINSOCK2', 'ws2_32 iphlpapi');
	} elsif ($os =~ /^windows/) {
		MkEmulWindows('WINSOCK1', 'wsock32');
		MkEmulUnavail('WINSOCK2');
	}
	return (1);
}

BEGIN
{
	my $n = 'winsock';

	$DESCR{$n}   = 'WinSock';
	$TESTS{$n}   = \&TEST_winsock;
	$DISABLE{$n} = \&DISABLE_winsock;
	$EMUL{$n}    = \&EMUL_winsock;
}
;1
