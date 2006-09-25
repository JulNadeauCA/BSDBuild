# $Csoft: sdl.pm,v 1.17 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2006 CubeSoft Communications, Inc.
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
	
	MkExecOutput('perl', '-MExtUtils::Embed -e ccopts', 'PERL_CFLAGS');
	MkExecOutput('perl', '-MExtUtils::Embed -e ldopts', 'PERL_LIBS');
	
	MkIf('"${PERL_LIBS}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether libperl works...');
		MkCompileC('HAVE_PERL', '${PERL_CFLAGS}', '${PERL_LIBS}', << 'EOF');
#include <EXTERN.h>
#include <perl.h>

static void xs_init (pTHX);
EXTERN_C void boot_DynaLoader(pTHX_ CV *cv);
EXTERN_C void xs_init(pTHX) {
	char *file = __FILE__;
	dXSUB_SYS;
	newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}
int
main(int argc, char **argv, char **env)
{
	PerlInterpreter *myPerl;
	char *myArgv[] = { "", "foo.pl" };

	PERL_SYS_INIT3(&argc, &argv, &env);
	myPerl = perl_alloc();
	perl_construct(myPerl);
	perl_parse(myPerl, xs_init, 2, myArgv, (char **)NULL);
	PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
	perl_run(myPerl);
	return (0);
}
EOF
		MkIf('"${HAVE_PERL}" != ""');
			MkSaveMK('PERL_CFLAGS', 'PERL_LIBS');
			MkSaveDefine('PERL_CFLAGS', 'PERL_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_PERL');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'perl'} = \&Test;
	$DESCR{'perl'} = 'Perl (http://www.cpan.org)';
}

;1
