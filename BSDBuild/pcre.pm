# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <pcre.h>

int
main(int argc, char *argv[])
{
	pcre *re;
	const char *error;
	int eo, rc;
	int ovector[30];

	if (!(re = pcre_compile("(.*)(subject)+", PCRE_CASELESS, &error, &eo, NULL))) {
		rc = pcre_exec(re, NULL, "Subject", strlen("subject"), 0, 0, ovector, 30);
		pcre_free(re);
		return (0);
	}
	return (1);
}
EOF

sub TEST_pcre
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'pcre-config', '--version', 'PCRE_VERSION');
	MkExecOutputPfx($pfx, 'pcre-config', '--cflags', 'PCRE_CFLAGS');
	MkExecOutputPfx($pfx, 'pcre-config', '--libs', 'PCRE_LIBS');

	MkIfFound($pfx, $ver, 'PCRE_VERSION');
		MkPrintSN('checking whether PCRE works...');
		MkCompileC('HAVE_PCRE', '${PCRE_CFLAGS}', '${PCRE_LIBS}', $testCode);
		MkSave('PCRE_CFLAGS', 'PCRE_LIBS');
	MkElse;
		MkSaveUndef('HAVE_PCRE');
	MkEndif;
}

sub DISABLE_pcre
{
	MkDefine('HAVE_PCRE', 'no');
	MkSaveUndef('HAVE_PCRE');
}

BEGIN
{
	my $n = 'pcre';

	$DESCR{$n}   = 'PCRE library';
	$URL{$n}     = 'http://www.pcre.org';
	$TESTS{$n}   = \&TEST_pcre;
	$DISABLE{$n} = \&DISABLE_pcre;
	$DEPS{$n}    = 'cc';
}
;1
