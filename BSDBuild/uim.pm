# Public domain

my $testCode = << 'EOF';
#include <uim.h>
#include <uim-util.h>

int main(int argc, char *argv[]) {
	uim_context uimCtx;
	const char *s;
	int i;

	uimCtx = uim_create_context(NULL, "UTF-8", NULL, NULL, uim_iconv, NULL);
	for (i = 0; i < uim_get_nr_im(uimCtx); i++) {
		s = uim_get_im_name(uimCtx, i);
		if (s == NULL) { return (1); }
	}
	uim_release_context(uimCtx);
	return (0);
}
EOF

sub TEST_uim
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'uim', '--modversion', 'UIM_VERSION');
	MkExecPkgConfig($pfx, 'uim', '--cflags', 'UIM_CFLAGS');
	MkExecPkgConfig($pfx, 'uim', '--libs', 'UIM_LIBS');
	MkIfFound($pfx, $ver, 'UIM_VERSION');
		MkPrintSN('checking whether uim works...');
		MkCompileC('HAVE_UIM', '${UIM_CFLAGS}', '${UIM_LIBS}', $testCode);
		MkIfFalse('${HAVE_UIM}');
			MkDisableFailed('uim');
		MkEndif;
	MkElse;
		MkDisableNotFound('uim');
	MkEndif;
	
	MkIfTrue('${HAVE_UIM}');
		MkDefine('UIM_PC', 'uim');
	MkEndif;
}

sub DISABLE_uim
{
	MkDefine('HAVE_UIM', 'no') unless $TestFailed;
	MkDefine('UIM_CFLAGS', '');
	MkDefine('UIM_LIBS', '');
	MkSaveUndef('HAVE_UIM');
}

BEGIN
{
	my $n = 'uim';

	$DESCR{$n}   = 'uim framework';
	$URL{$n}     = 'http://code.google.com/p/uim';
	$TESTS{$n}   = \&TEST_uim;
	$DISABLE{$n} = \&DISABLE_uim;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'UIM_CFLAGS UIM_LIBS UIM_PC';
}
;1
