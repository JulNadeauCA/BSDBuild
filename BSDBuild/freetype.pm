# Public domain

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

sub TEST_freetype
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
		MkIfFalse('${HAVE_FREETYPE}');
			MkDisableFailed('freetype');
		MkEndif;
	MkElse;
		MkDisableNotFound('freetype');
	MkEndif;
	
	MkIfTrue('${HAVE_FREETYPE}');
		MkDefine('FREETYPE_PC', 'freetype2');
	MkEndif;
}

sub DISABLE_freetype
{
	MkDefine('HAVE_FREETYPE', 'no') unless $TestFailed;
	MkDefine('FREETYPE_CFLAGS', '');
	MkDefine('FREETYPE_LIBS', '');
	MkSaveUndef('HAVE_FREETYPE');
}

sub EMUL_freetype
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

	$DESCR{$n}   = 'FreeType';
	$URL{$n}     = 'http://www.freetype.org';
	$TESTS{$n}   = \&TEST_freetype;
	$DISABLE{$n} = \&DISABLE_freetype;
	$EMUL{$n}    = \&EMUL_freetype;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'FREETYPE_CFLAGS FREETYPE_LIBS FREETYPE_PC';
}
;1
