# vim:ts=4
#
# Copyright (c) 2005 Hypertriton, Inc. <http://hypertriton.com/>
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
	MkCompileC('_MK_HAVE_SYS_TYPES_H', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	size_t len = 1;
	len++;
	return (0);
}
EOF
	MkIfTrue('${_MK_HAVE_SYS_TYPES_H}');
		MkPrintN('checking for int64_t type...');
		MkCompileC('HAVE_INT64_T', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	int64_t i64 = 0;
	u_int64_t u64 = 0;
	return (i64 != 0 || u64 != 0);
}
EOF
		MkPrintN('checking for __int64 type...');
		MkCompileC('HAVE___INT64', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	__int64 i64 = 0;
	return (i64 != 0);
}
EOF
		MkIfTrue('${HAVE_INT64_T}');
			MkDefine('HAVE_64BIT', "yes");
			MkSaveDefine('HAVE_64BIT');
		MkEndif;
		MkIfTrue('${HAVE___INT64}');
			MkDefine('HAVE_64BIT', "yes");
			MkSaveDefine('HAVE_64BIT');
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_64BIT');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindowsSYS('_MK_HAVE_SYS_TYPES_H');
		if ($os =~ /64/) {
			MkEmulWindowsSYS('64BIT');
		} else {
			MkEmulUnavailSYS('64BIT');
		}
	} else {
		MkEmulUnavailSYS('_MK_HAVE_SYS_TYPES_H');
		MkEmulUnavailSYS('64BIT');
	}
	return (1);
}

BEGIN
{
	$DESCR{'sys_types'} = '<sys/types.h>';
	$TESTS{'sys_types'} = \&Test;
	$EMUL{'sys_types'} = \&Emul;
	$DEPS{'sys_types'} = 'cc';
}

;1
