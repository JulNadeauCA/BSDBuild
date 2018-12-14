# vim:ts=4
# Public domain

sub TEST_perl
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
		
		MkSet('PERL', '${MK_EXEC_PATH}');
		MkSaveMK('PERL');
	MkElse;
		MkPrintS('no');
		DISABLE_perl();
	MkEndif;
}

sub DISABLE_perl
{
	MkDefine('HAVE_PERL', 'no');
	MkDefine('PERL_CFLAGS', '');
	MkDefine('PERL_LIBS', '');
	MkSaveUndef('HAVE_PERL');
	
	MkDefine('PERL', '/usr/bin/env perl');		# Default
	MkSaveMK('PERL');
}

BEGIN
{
	my $n = 'perl';

	$DESCR{$n}   = 'perl';
	$URL{$n}     = 'http://www.cpan.org';
	$TESTS{$n}   = \&TEST_perl;
	$DISABLE{$n} = \&DISABLE_perl;
	$DEPS{$n}    = 'cc';
}
;1
