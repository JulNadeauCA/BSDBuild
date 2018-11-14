# Public domain
# vim:ts=4

sub Test
{
	MkPrintS("not checking");
	Disable_WinSock();
	return (0);
}

sub Disable_WinSock
{
	MkDefine('HAVE_WINSOCK1', 'no');
	MkDefine('HAVE_WINSOCK2', 'no');
	MkSaveUndef('HAVE_WINSOCK1', 'HAVE_WINSOCK2');
}

sub Emul
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

	$DESCR{$n} = 'the WinSock interface';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable_WinSock;
	$EMUL{$n}    = \&Emul;
}

;1
