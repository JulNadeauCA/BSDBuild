# $Csoft: glib.pm,v 1.9 2003/10/01 09:24:19 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002-2007 CubeSoft Communications, Inc.
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
	my ($ver) = @_;
	
	MkExecOutput('glib-config', '--version', 'GLIB_VERSION');
	MkExecOutput('glib-config', '--cflags', 'GLIB_CFLAGS');
	MkExecOutput('glib-config', '--libs', 'GLIB_LIBS');

	# Hack for FreeBSD port
	MkExecOutput('glib12-config', '--version', 'glib12_version');
	MkExecOutput('glib12-config', '--cflags', 'glib12_cflags');
	MkExecOutput('glib12-config', '--libs', 'glib12_libs');

	MkIf('"${GLIB_VERSION}" != ""');
		# TODO: Test
		MkSaveDefine('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
		MkSaveMK	('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
		MkPrint('yes');
	MkElse;
		MkIf('"${glib12_version}" != ""');
			MkDefine	('GLIB_CFLAGS', '${glib12_cflags}');
			MkDefine	('GLIB_LIBS', '${glib12_libs}');
			MkSaveDefine('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
			MkSaveMK	('HAVE_GLIB', 'GLIB_CFLAGS', 'GLIB_LIBS');
			MkPrint('yes');
		MkElse;
			MkSaveUndef	('HAVE_GLIB');
			MkPrint('no');
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
