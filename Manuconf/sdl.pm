# $Csoft: sdl.pm,v 1.2 2002/05/05 23:27:03 vedge Exp $
#
# Copyright (c) 2002 CubeSoft Communications <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistribution in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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
	my ($require, $ver) = @_;

	print SHObtain('sdl-config', '--version', 'SDL_VERSION');
	print SHObtain('sdl-config', '--cflags', 'SDL_CFLAGS');
	print SHObtain('sdl-config', '--libs', 'SDL_LIBS');
	print SHObtain('sdl11-config', '--version', 'SDL11_VERSION');
	print SHObtain('sdl11-config', '--cflags', 'SDL11_CFLAGS');
	print SHObtain('sdl11-config', '--libs', 'SDL11_LIBS');

	print
	    SHTest('"$SDL_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHMKSave('SDL_CFLAGS') .
	        SHMKSave('SDL_LIBS'),
	    SHNothing());
	print
	    SHTest('"$SDL11_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHDefine('SDL_CFLAGS', '$SDL11_CFLAGS') .
	        SHDefine('SDL_LIBS', '$SDL11_LIBS') .
	        SHMKSave('SDL_CFLAGS') .
	        SHMKSave('SDL_LIBS'),
	    SHNothing());
	print
	    SHTest('"$SDL_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHRequire('SDL', $ver, 'http://www.libsdl.org/'));

	return (0);
}

BEGIN
{
	$TESTS{'sdl'} = \&Test;
	$DESCR{'sdl'} = 'SDL (http://www.libsdl.org)';
}

;1
