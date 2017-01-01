# vim:ts=4
#
# Copyright (c) 2006-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

	MkExecOutputPfx($pfx, 'perl', '-MExtUtils::Embed -e ccopts', 'PERL_CFLAGS');
	MkExecOutputPfx($pfx, 'perl', '-MExtUtils::Embed -e ldopts', 'PERL_LIBS');
	
	MkIfNE('${PERL_LIBS}', '');
		MkPrintS('yes');
		MkPrintSN('checking whether libperl works...');
		MkCompileC('HAVE_PERL', '${PERL_CFLAGS} -Wno-error', '${PERL_LIBS}', << 'EOF');
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
	PerlInterpreter *my_perl;
	char *myArgv[] = { "", "foo.pl" };

	PERL_SYS_INIT3(&argc, &argv, &env);
	my_perl = perl_alloc();
	perl_construct(my_perl);
	perl_parse(my_perl, xs_init, 2, myArgv, (char **)NULL);
	PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
	perl_run(my_perl);
	return (0);
}
EOF
		MkSaveIfTrue('${HAVE_PERL}', 'PERL_CFLAGS', 'PERL_LIBS');
		
		Which('perl', undef, 'PERL');
		MkSaveMK('PERL');
	MkElse;
		MkPrintS('no');
		MkSaveUndef('HAVE_PERL');

		MkDefine('PERL', '/usr/bin/perl');
		MkSaveMK('PERL');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'perl'} = 'Perl';
	$URL{'perl'} = 'http://www.cpan.org';

	$TESTS{'perl'} = \&Test;
	$DEPS{'perl'} = 'cc';
}

;1
