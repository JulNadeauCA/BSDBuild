# $Csoft: smpeg.pm,v 1.4 2002/05/06 00:00:20 vedge Exp $
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
	my ($ver) = @_;
	
	print Obtain('smpeg-config', '--version', 'smpeg_version');
	print Obtain('smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	print Obtain('smpeg-config', '--libs', 'SMPEG_LIBS');

	print
	    Test('"${smpeg_version}" != ""',
	    Echo("ok") . 
	    	HSave('CONF_SMPEG') .
	        MKSave('SMPEG_CFLAGS') .
	        MKSave('SMPEG_LIBS'),
	    Fail('missing'));

	return (0);
}

BEGIN
{
	$HOMEPAGE = 'http://www.lokigames.com/development/smpeg.php3';
	$DESCR{'smpeg'} = "smpeg ($HOMEPAGE)";
	$TESTS{'smpeg'} = \&Test;
}

;1
