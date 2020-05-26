# Public domain

use BSDBuild::Core;

my $testCode = << 'EOF';
#include <stdio.h>
#include <png.h>

int main(int argc, char *argv[])
{
	char foo[4];

	if (png_sig_cmp((png_bytep)foo, 0, 3)) {
		return (1);
	}
	return (0);
}
EOF

sub TEST_png
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'libpng-config', '--version', 'PNG_VERSION');
	MkExecOutputPfx($pfx, 'libpng-config', '--cflags', 'PNG_CFLAGS');
	MkExecOutputPfx($pfx, 'libpng-config', '--L_opts', 'PNG_LOPTS');
	MkExecOutputPfx($pfx, 'libpng-config', '--libs', 'PNG_LIBS');
	MkDefine('PNG_LIBS', '${PNG_LOPTS} ${PNG_LIBS}');
	MkIfFound($pfx, $ver, 'PNG_VERSION');
		MkPrintSN('checking whether libpng works...');
		MkCompileC('HAVE_PNG', '${PNG_CFLAGS}', '${PNG_LIBS}', $testCode);
		MkIfFalse('${HAVE_PNG}');
			MkDisableFailed('png');
		MkElse;
			MkTestVersion('PNG_VERSION', '1.4.0');
			MkIfEQ('${MK_VERSION_OK}', 'yes');
				MkDefine('HAVE_LIBPNG14', 'yes');
				MkSaveDefine('HAVE_LIBPNG14');
			MkElse;
				MkDefine('HAVE_LIBPNG14', 'no');
				MkSaveUndef('HAVE_LIBPNG14');
			MkEndif;
		MkEndif;
	MkElse;
		MkDisableNotFound('png');
	MkEndif;

	MkIfTrue('${HAVE_PNG}');
		MkDefine('PNG_PC', 'libpng');
	MkEndif;
}

sub DISABLE_png
{
	MkDefine('HAVE_PNG', 'no') unless $TestFailed;
	MkDefine('PNG_CFLAGS', '');
	MkDefine('PNG_LIBS', '');
	MkSaveUndef('HAVE_PNG', 'HAVE_LIBPNG14');
}

BEGIN
{
	my $n = 'png';

	$DESCR{$n}   = 'libpng';
	$URL{$n}     = 'http://www.libpng.org';
	$TESTS{$n}   = \&TEST_png;
	$DISABLE{$n} = \&DISABLE_png;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'PNG_CFLAGS PNG_LIBS PNG_PC';
}
;1
