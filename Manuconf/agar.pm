# $Csoft: sdl.pm,v 1.16 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2004 CubeSoft Communications, Inc.
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
	
	print ReadOut('agar-config', '--version', 'agar_version');
	print ReadOut('agar-config', '--cflags', 'AGAR_CFLAGS');
	print ReadOut('agar-config', '--libs', 'AGAR_LIBS');
	
	print
	    Cond('"${agar_version}" != ""',
	    Echo("yes") . 
	    	HDefine('HAVE_AGAR') .
	        MKSave('AGAR_CFLAGS') .
	        MKSave('AGAR_LIBS'),
	    Echo("no") .
		    HUndef('HAVE_AGAR'));

	print NEcho('checking whether Agar works...');
	TryLibCompile 'HAVE_AGAR',
	    '${AGAR_CFLAGS}', '${AGAR_LIBS}', << 'EOF';
#include <engine/engine.h>
#include <stdio.h>

static struct engine_proginfo info = { "test", "Test", "", "1.0" };

int
main(int argc, char *argv[])
{
	engine_init(argc, argv, &info, ENGINE_INIT_GFX);
	prop_set_bool(config, "foo", 1);
	event_loop();
	engine_destroy();
	return (0);
}
EOF
	print
	    Cond('"${HAVE_AGAR}" = "yes"',
	    Nothing(),
	    Fail('The Agar test application failed to compile.'));

	return (0);
}

BEGIN
{
	$TESTS{'agar'} = \&Test;
	$DESCR{'agar'} = 'Agar (http://agar.csoft.org/)';
}

;1
