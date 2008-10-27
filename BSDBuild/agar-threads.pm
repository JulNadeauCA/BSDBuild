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
	my ($ver) = @_;
	
	MkExecOutputUnique('agar-config', '--threads', 'AGAR_HAVE_THREADS');
	MkIf('"${AGAR_HAVE_THREADS}" = "yes"');
		MkPrint('yes');
		MkSaveMK('AGAR_HAVE_THREADS');
		MkSaveDefine('AGAR_HAVE_THREADS');
	MkElse;
	    MkPrint('no');
		MkSaveMK('AGAR_HAVE_THREADS');
		MkSaveUndef('AGAR_HAVE_THREADS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkDefine('AGAR_HAVE_THREADS', 'yes');
	MkSaveMK('AGAR_HAVE_THREADS');
	MkSaveDefine('AGAR_HAVE_THREADS');
	return (1);
}

sub Link
{
	return (0);
}

BEGIN
{
	$TESTS{'agar-threads'} = \&Test;
	$DEPS{'agar-threads'} = 'agar';
	$LINK{'agar-threads'} = \&Link;
	$EMUL{'agar-threads'} = \&Emul;
	$DESCR{'agar-threads'} = 'threads support in Agar';
}

;1
