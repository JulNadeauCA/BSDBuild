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
		MkPrintN('checking for 64-bit types...');
		MkCompileC('HAVE_64BIT', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	int64_t i64 = 0;
	u_int64_t u64 = 0;

	return (i64 != 0 || u64 != 0);
}
EOF
		MkPrintN('checking for conflicting typedefs...');
		#
		# XXX should check each type separatedly!
		#
		MkCompileC('_MK_HAVE_UNSIGNED_TYPEDEFS', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	Uchar foo = 1;
	Uint bar = 1;
	Ulong baz = 1;
	return (foo != 1 || bar != 1 || baz != 1);
}
EOF
	MkElse;
		MkSaveUndef('HAVE_64BIT');

		MkPrintN('checking for conflicting typedefs...');
		#
		# XXX should check each type separatedly!
		#
		MkCompileC('_MK_HAVE_UNSIGNED_TYPEDEFS', '', '', << 'EOF');
int main(int argc, char *argv[]) {
	Uchar foo = 1;
	Uint bar = 1;
	Ulong baz = 1;
	return (foo != 1 || bar != 1 || baz != 1);
}
EOF
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os eq 'windows' ||
	    $os =~ /^(open|net|free)bsd$/) {
		MkDefine('_MK_HAVE_SYS_TYPES_H', 'yes');
		MkSaveDefine('_MK_HAVE_SYS_TYPES_H');
	} else {
		MkSaveUndef('_MK_HAVE_SYS_TYPES_H');
	}
	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_64BIT', 'yes');
		MkSaveDefine('HAVE_64BIT');
	} else {
		MkSaveUndef('HAVE_64BIT');
	}
	MkSaveUndef('_MK_HAVE_UNSIGNED_TYPEDEFS');
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
