# vim:ts=4
#
# Copyright (c) 2007 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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
	MkPrint('');
	MkPrintN('checking for BIG_ENDIAN...');
	MkCompileAndRunC('_MK_BIG_ENDIAN', '', '', << 'EOF');
#include <sys/types.h>
#include <sys/param.h>
int
main(int argc, char *argv[])
{
#if BYTE_ORDER == BIG_ENDIAN
	return (0);
#else
	return (1);
#endif
}
EOF
	MkIf('"${_MK_BIG_ENDIAN}" = "yes"');
		MkDefine('_MK_LITTLE_ENDIAN', 'no');
		MkSaveUndef('_MK_LITTLE_ENDIAN');
	MkElse;
		MkPrintN('checking for LITTLE_ENDIAN...');
		MkCompileAndRunC('_MK_LITTLE_ENDIAN', '', '', << 'EOF');
#include <sys/types.h>
#include <sys/param.h>
int
main(int argc, char *argv[])
{
#if BYTE_ORDER == LITTLE_ENDIAN
	return (0);
#else
	return (1);
#endif
}
EOF
		MkIf('"${_MK_LITTLE_ENDIAN}" = "yes"');
			MkDefine('_MK_BIG_ENDIAN', 'no');
			MkSaveUndef('_MK_BIG_ENDIAN');
		MkElse;
			MkPrintN('checking for little endian byte order...');
			MkCompileAndRunC('_MK_LITTLE_ENDIAN', '', '', << 'EOF');
int
main(int argc, char *argv[])
{
	union {
		long l;
		char c[sizeof (long)];
	} u;
	u.l = 1;
	return (u.c[sizeof (long) - 1] == 1);
}
EOF
			MkIf('"${MK_COMPILE_STATUS}" != "OK"');
				MkFail('Unable to determine byte order');
			MkEndif;
			MkIf('"${_MK_LITTLE_ENDIAN}" = "no"');
				MkDefine('_MK_BIG_ENDIAN', 'yes');
				MkSaveDefine('_MK_BIG_ENDIAN');
			MkEndif;
		MkEndif;
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($machine =~ /^(hppa|m68k|mc68000|mips|mipseb|ppc|sparc|sparc64)$/) {
		MkDefine('_MK_BIG_ENDIAN', 'yes');
		MkSaveDefine('_MK_BIG_ENDIAN');
		MkSaveUndef('_MK_LITTLE_ENDIAN');
	} else {
		MkDefine('_MK_LITTLE_ENDIAN', 'yes');
		MkSaveDefine('_MK_LITTLE_ENDIAN');
		MkSaveUndef('_MK_BIG_ENDIAN');
	}
	return (1);
}

BEGIN
{
	$TESTS{'byte_order'} = \&Test;
	$DEPS{'byte_order'} = 'cc';
	$EMUL{'byte_order'} = \&Emul;
	$DESCR{'byte_order'} = 'byte order';
}

;1
