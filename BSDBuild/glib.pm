# vim:ts=4
#
# Copyright (c) 2002-2007 Hypertriton, Inc. <http://hypertriton.com/>
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
	
	MkExecOutputPfx($pfx, 'glib-config', '--version', 'GLIB_VERSION');
	MkExecOutputPfx($pfx, 'glib-config', '--cflags', 'GLIB_CFLAGS');
	MkExecOutputPfx($pfx, 'glib-config', '--libs', 'GLIB_LIBS');
	
	MkCaseIn('${host}');
	MkCaseBegin('*-*-freebsd*');
		MkExecOutputPfx($pfx, 'glib12-config', '--version', 'glib12_version');
		MkExecOutputPfx($pfx, 'glib12-config', '--cflags', 'glib12_cflags');
		MkExecOutputPfx($pfx, 'glib12-config', '--libs', 'glib12_libs');
		MkCaseEnd;
	MkEsac;

	MkIfNE('${GLIB_VERSION}', '');
		MkFoundVer($pfx, $ver, 'GLIB_VERSION');
		MkSave('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
	MkElse;
		MkIfNE('${glib12_version}', '');
			MkFoundVer($pfx, $ver, 'glib12_version');
			MkDefine('GLIB_CFLAGS', '${glib12_cflags}');
			MkDefine('GLIB_LIBS', '${glib12_libs}');
			MkSave('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
			MkPrint('yes');
		MkElse;
			MkNotFound($pfx);
			MkSaveUndef('HAVE_GLIB');
		MkEndif;
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'glib'} = 'Glib (http://www.gtk.org/)';
	$TESTS{'glib'} = \&Test;
	$DEPS{'glib'} = 'cc';
}
;1
