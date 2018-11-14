# Public domain
# vim:ts=4

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

sub Test
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
		MkSaveIfTrue('${HAVE_PNG}', 'PNG_CFLAGS', 'PNG_LIBS');
		
		MkTestVersion('PNG_VERSION', '1.4.0');
		MkIfVersionOK;
			MkDefine('HAVE_LIBPNG14', 'yes');
			MkSave('HAVE_LIBPNG14');
		MkElse;
			MkSaveUndef('HAVE_LIBPNG14');
		MkEndif;
	MkElse;
		Disable();
	MkEndif;
	
	MkIfTrue('${HAVE_PNG}');
		MkDefine('PNG_PC', 'libpng');
	MkElse;
		MkDefine('PNG_PC', '');
	MkEndif;
	return (0);
}

sub Disable
{
	MkDefine('HAVE_PNG', 'no');
	MkDefine('HAVE_LIBPNG14', 'no');
	MkDefine('PNG_CFLAGS', '');
	MkDefine('PNG_LIBS', '');
	MkDefine('PNG_PC', '');

	MkSaveUndef('HAVE_PNG', 'HAVE_LIBPNG14', 'PNG_CFLAGS', 'PNG_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('PNG');

	MkDefine('HAVE_LIBPNG14', 'no');
	MkSaveMK('HAVE_LIBPNG14');
	MkSaveUndef('HAVE_LIBPNG14');
	return (1);
}

BEGIN
{
	my $n = 'png';

	$DESCR{$n} = 'libpng';
	$URL{$n}   = 'http://www.libpng.org';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}
;1
