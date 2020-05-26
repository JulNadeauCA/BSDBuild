# Public domain

my $testCode = << 'EOF';
#include <string.h>
#ifdef HAVE_DLFCN_H
#include <dlfcn.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	char *error;
	handle = dlopen("foo.so", 0);
	error = dlerror();
	(void)dlsym(handle, "foo");
	return (error != NULL);
}
EOF

sub TEST_dlopen
{
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_DLFCN_H',	'<dlfcn.h>');
	TryCompile('HAVE_DLOPEN', $testCode);
	MkIfFalse('${HAVE_DLOPEN}');
		MkPrintSN('checking for dlopen() in -ldl...');
		TryCompileFlagsC('HAVE_DLOPEN', '-ldl', $testCode);
		MkIfTrue('${HAVE_DLOPEN}');
			MkDefine('DSO_CFLAGS', '');
			MkDefine('DSO_LIBS', '-ldl');
		MkElse;
			MkDisableFailed('dlopen');
		MkEndif;
	MkEndif;
	EndTestHeaders();
}

sub DISABLE_dlopen
{
	MkDefine('HAVE_DLOPEN', 'no') unless $TestFailed;
	MkDefine('HAVE_DLFCN_H', 'no');
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');
	MkSaveUndef('HAVE_DLOPEN', 'HAVE_DLFCN_H');
}

BEGIN
{
	my $n = 'dlopen';

	$DESCR{$n}   = 'dlopen() interface';
	$TESTS{$n}   = \&TEST_dlopen;
	$DISABLE{$n} = \&DISABLE_dlopen;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DSO_CFLAGS DSO_LIBS';
}
;1
