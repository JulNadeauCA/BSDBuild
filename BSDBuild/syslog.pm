# vim:ts=4
#
# Copyright (c) 2009 Hypertriton, Inc. <http://hypertriton.com/>
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
	TryCompile 'HAVE_SYSLOG', << 'EOF';
#include <syslog.h>
#include <stdarg.h>
int
main(int argc, char *argv[])
{
	syslog(LOG_DEBUG, "foo %d", 1);
	return (0);
}
EOF
	
	MkPrintN('checking for syslog_r()...');
	TryCompile 'HAVE_SYSLOG_R', << 'EOF';
#include <syslog.h>
#include <stdarg.h>
int
main(int argc, char *argv[])
{
	struct syslog_data sdata = SYSLOG_DATA_INIT;
	syslog_r(LOG_ERR, &sdata, "foo %d", 1);
	return (0);
}
EOF

	MkPrintN('checking for vsyslog()...');
	TryCompile 'HAVE_VSYSLOG', << 'EOF';
#include <syslog.h>
#include <stdarg.h>

void
foofn(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	vsyslog(LOG_DEBUG, fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	foofn("foo %d", 1);
	return (0);
}
EOF
	
	MkPrintN('checking for vsyslog_r()...');
	TryCompile 'HAVE_VSYSLOG_R', << 'EOF';
#include <syslog.h>
#include <stdarg.h>

void
foofn(const char *fmt, ...)
{
	va_list ap;
	struct syslog_data sdata = SYSLOG_DATA_INIT;
	va_start(ap, fmt);
	vsyslog_r(LOG_DEBUG, &sdata, fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	foofn("foo %d", 1);
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_SYSLOG', 'yes');
		MkSaveDefine('HAVE_SYSLOG');
		MkDefine('HAVE_VSYSLOG', 'yes');
		MkSaveDefine('HAVE_VSYSLOG');
	} else {
		MkSaveUndef('HAVE_SYSLOG');
		MkSaveUndef('HAVE_VSYSLOG');
	}
	return (1);
}

BEGIN
{
	$DESCR{'syslog'} = 'a syslog() function';
	$TESTS{'syslog'} = \&Test;
	$EMUL{'syslog'} = \&Emul;
	$DEPS{'syslog'} = 'cc';
}

;1
