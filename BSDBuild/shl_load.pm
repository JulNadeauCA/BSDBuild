# Public domain

my $testCode = << 'EOF';
#include <string.h>
#ifdef HAVE_DL_H
#include <dl.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	void **p;

	handle = shl_load("foo.so", BIND_IMMEDIATE, 0);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_PROCEDURE, p);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_DATA, p);
	shl_unload((shl_t)handle);
	return (handle != NULL);
}
EOF

sub TEST_shl_load
{
	my ($ver, $pfx) = @_;

	BeginTestHeaders();
	DetectHeaderC('HAVE_DL_H', '<dl.h>');

	MkIfNE($pfx, '');
		MkDefine('SHL_LOAD_LIBS', "-L$pfx -ldld");
	MkElse;
		MkDefine('SHL_LOAD_LIBS', '-ldld');
	MkEndif;

	TryCompileFlagsC('HAVE_SHL_LOAD', '${SHL_LOAD_LIBS}', $testCode);
	MkIfTrue('${HAVE_SHL_LOAD}');
		MkDefine('DSO_LIBS', '$DSO_LIBS $SHL_LOAD_LIBS');
		MkSaveDefine('HAVE_SHL_LOAD');
	MkElse;
		MkDisableFailed('shl_load');
	MkEndif;

	EndTestHeaders();
}

sub DISABLE_shl_load
{
	MkDefine('HAVE_SHL_LOAD', 'no') unless $TestFailed;
	MkDefine('HAVE_DL_H', 'no');
	MkDefine('SHL_LOAD_LIBS', '');
	MkSaveUndef('HAVE_SHL_LOAD', 'HAVE_DL_H');
}

BEGIN
{
	my $n = 'shl_load';

	$DESCR{$n}   = 'the shl_load() interface';
	$TESTS{$n}   = \&TEST_shl_load;
	$DISABLE{$n} = \&DISABLE_shl_load;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DSO_LIBS SHL_LOAD_LIBS';
}
;1
