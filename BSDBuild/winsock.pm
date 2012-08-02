# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sub Test
{
	MkDefine('HAVE_WINSOCK1', 'no');
	MkDefine('HAVE_WINSOCK2', 'no');
	MkSaveUndef('HAVE_WINSOCK1', 'HAVE_WINSOCK2');
	return (1);
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
	$DESCR{'winsock'} = 'the WinSock interface';
	$TESTS{'winsock'} = \&Test;
	$EMUL{'winsock'} = \&Emul;
}

;1
