# $Csoft: glib.pm,v 1.8 2003/08/07 19:36:11 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003 CubeSoft Communications, Inc.
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
	
	print ReadOut('glib-config', '--version', 'glib_version');
	print ReadOut('glib-config', '--cflags', 'GLIB_CFLAGS');
	print ReadOut('glib-config', '--libs', 'GLIB_LIBS');

	# FreeBSD port
	print ReadOut('glib12-config', '--version', 'glib12_version');
	print ReadOut('glib12-config', '--cflags', 'glib12_cflags');
	print ReadOut('glib12-config', '--libs', 'glib12_libs');
	
	print
	    Cond('"${glib_version}" != ""',
	    Define('glib_found', 'yes') .
	        MKSave('GLIB_CFLAGS') .
	        MKSave('GLIB_LIBS'),
	    Nothing());
	print
	    Cond('"${glib12_version}" != ""',
	    Define('glib_found', 'yes') .
	        Define('GLIB_CFLAGS', '$glib12_cflags') .
	        Define('GLIB_LIBS', '$glib12_libs') .
	        MKSave('GLIB_CFLAGS') .
	        MKSave('GLIB_LIBS'),
	    Nothing());
	print
	    Cond('"${glib_found}" = "yes"',
	    Echo('ok'),
	    Fail("glib missing"));

	return (0);
}

BEGIN
{
	$TESTS{'glib'} = \&Test;
	$DESCR{'glib'} = 'Glib (http://www.gtk.org/)';
}

;1
