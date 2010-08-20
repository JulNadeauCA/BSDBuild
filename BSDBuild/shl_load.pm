# vim:ts=4
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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
	my ($ver, $pfx) = @_;

	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_DL_H', '<dl.h>');

	MkIfNE($pfx, '');
		MkDefine('DSO_LIBS', "-L$pfx -ldld");
	MkElse;
		MkDefine('DSO_LIBS', '-ldld');
	MkEndif;

	TryCompileFlagsC 'HAVE_SHL_LOAD', '${DSO_LIBS}', << 'EOF';
#ifdef HAVE_DL_H
#include <dl.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	void **p;

	handle = shl_load("foo.so", BIND_IMMEDIATE, 0);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_PROCEDURE, p);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_DATA, p);
	shl_unload((shl_t)handle);
	return (0);
}
EOF
	MkSaveIfTrue('${HAVE_SHL_LOAD}', 'DSO_CFLAGS', 'DSO_LIBS');
	EndTestHeaders();
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkSaveUndef('HAVE_DL_H');
	MkSaveUndef('HAVE_SHL_LOAD');
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');
	MkSave('DSO_CFLAGS', 'DSO_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'shl_load'} = 'shl_load() interface';
	$TESTS{'shl_load'} = \&Test;
	$EMUL{'shl_load'} = \&Emul;
	$DEPS{'shl_load'} = 'cc';
}

;1
