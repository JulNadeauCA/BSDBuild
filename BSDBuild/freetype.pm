# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H
int
main(int argc, char *argv[])
{
	FT_Library library;
	FT_Face face;
	FT_Init_FreeType(&library);
	FT_New_Face(library, "foo", 0, &face);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkIfPkgConfig('freetype2');
		MkExecPkgConfig($pfx, 'freetype2', '--modversion', 'FREETYPE_VERSION');
		MkExecPkgConfig($pfx, 'freetype2', '--cflags', 'FREETYPE_CFLAGS');
		MkExecPkgConfig($pfx, 'freetype2', '--libs', 'FREETYPE_LIBS');
	MkElse;
	    MkExecOutputPfx($pfx, 'freetype-config', '--version', 'FREETYPE_VERSION');
	    MkExecOutputPfx($pfx, 'freetype-config', '--cflags', 'FREETYPE_CFLAGS');
	    MkExecOutputPfx($pfx, 'freetype-config', '--libs', 'FREETYPE_LIBS');
    MkEndif;

	MkCaseIn('${host}');
	MkCaseBegin('*-*-irix*');
		MkIfExists('/usr/freeware/include');
			MkAppend('FREETYPE_CFLAGS', '-I/usr/freeware/include');
		MkEndif;
		MkCaseEnd;
	MkEsac;

	MkIfFound($pfx, $ver, 'FREETYPE_VERSION');
		MkPrintSN('checking whether FreeType works...');
		MkCompileC('HAVE_FREETYPE', '${FREETYPE_CFLAGS}', '${FREETYPE_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_FREETYPE}', 'FREETYPE_CFLAGS', 'FREETYPE_LIBS');
	MkElse;
		Disable();
	MkEndif;
	
	MkIfTrue('${HAVE_FREETYPE}');
		MkDefine('FREETYPE_PC', 'freetype2');
	MkElse;
		MkDefine('FREETYPE_PC', '');
	MkEndif;
	return (0);
}

sub Disable
{
	MkDefine('FREETYPE_CFLAGS', '');
	MkDefine('FREETYPE_LIBS', '');
	MkDefine('FREETYPE_PC', '');

	MkSaveUndef('HAVE_FREETYPE', 'FREETYPE_CFFLAGS', 'FREETYPE_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREETYPE', 'freetype');
	} else {
		MkEmulUnavail('FREETYPE');
	}
	return (1);
}

BEGIN
{
	my $n = 'freetype';

	$DESCR{$n} = 'FreeType';
	$URL{$n}   = 'http://www.freetype.org';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}

;1
