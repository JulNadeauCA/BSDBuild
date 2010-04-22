# $Csoft: smpeg.pm,v 1.12 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003, 2004 CubeSoft Communications, Inc.
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
	
	MkExecOutput('smpeg-config', '--version', 'SMPEG_VERSION');
	MkExecOutput('smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	MkExecOutput('smpeg-config', '--libs', 'SMPEG_LIBS');

	# TODO Test

	MkIf('"${SMPEG_VERSION}" != ""');
		MkPrint('yes, found ${SMPEG_VERSION}');
		MkTestVersion('SMPEG_VERSION', $ver);

		MkSaveDefine('HAVE_SMPEG', 'SMPEG_CFLAGS', 'SMPEG_LIBS');
		MkSaveMK	('HAVE_SMPEG', 'SMPEG_CFLAGS', 'SMPEG_LIBS');
	MkElse;
		MkPrint('no');
		MkSaveUndef	('HAVE_SMPEG');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'smpeg'} = 'the smpeg library';
	$TESTS{'smpeg'} = \&Test;
	$DEPS{'smpeg'} = 'cc,sdl';
}

;1
