# vim:ts=4
#
# Copyright (c) 2002-2011 Hypertriton, Inc. <http://hypertriton.com/>
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
my $testCode = << 'EOF';
#include <glib.h>
int main(int argc, char *argv[]) {
  void *slist = g_slist_alloc();
  g_slist_free(slist);
  return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'glib-2.0', '--modversion', 'GLIB2_VERSION');
	MkExecPkgConfig($pfx, 'glib-2.0', '--cflags', 'GLIB2_CFLAGS');
	MkExecPkgConfig($pfx, 'glib-2.0', '--libs', 'GLIB2_LIBS');
	MkIfFound($pfx, $ver, 'GLIB2_VERSION');
		MkPrintSN('checking whether glib 2.x works...');
		MkCompileC('HAVE_GLIB2',
			   '${GLIB2_CFLAGS}', '${GLIB2_LIBS}',
			    $testCode);
		MkSaveIfTrue('${HAVE_GLIB2}', 'GLIB2_CFLAGS', 'GLIB2_LIBS');
	MkElse;
		MkSaveUndef('HAVE_GLIB2');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'glib2'} = 'Glib 2.x';
	$URL{'glib2'} = 'http://www.gtk.org';

	$TESTS{'glib2'} = \&Test;
	$DEPS{'glib2'} = 'cc';
}
;1
