# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://www.hypertriton.com/>
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
	TryCompile 'HAVE_SIOCGIFCONF', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <netdb.h>
int
main(int argc, char *argv[])
{
	char buf[4096];
	struct ifconf conf;
	struct ifreq *ifr;
	int sock;
	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		return (1);
	}
	conf.ifc_len = sizeof(buf);
	conf.ifc_buf = (caddr_t)buf;
	if (ioctl(sock, SIOCGIFCONF, &conf) < 0) {
		return (1);
	}
#if !defined(_SIZEOF_ADDR_IFREQ)
#define _SIZEOF_ADDR_IFREQ sizeof
#endif
	for (ifr = (struct ifreq *)buf;
	     (char *)ifr < &buf[conf.ifc_len];
	     ifr = (struct ifreq *)((char *)ifr + _SIZEOF_ADDR_IFREQ(*ifr))) {
		if (ifr->ifr_addr.sa_family == AF_INET)
			return (1);
	}
	close(sock);
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavailSYS('SIOCGIFCONF');
	return (1);
}

BEGIN
{
	$TESTS{'siocgifconf'} = \&Test;
	$DEPS{'siocgifconf'} = 'cc';
	$EMUL{'siocgifconf'} = \&Emul;
	$DESCR{'siocgifconf'} = 'the SIOCGIFCONF interface';
}

;1
