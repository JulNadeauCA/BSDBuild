# vim:ts=4
# Public domain

sub TEST_sdl_cpuinfo
{
	MkCompileC('HAVE_SDL_CPUINFO', '', '', << 'EOF');
#include <SDL_cpuinfo.h>
int main(int argc, char *argv[]) {
	int c = 0;
	if (SDL_HasMMX()) { c = 1; }
	return (0);
}
EOF
}

sub DISABLE_sdl_cpuinfo
{
	MkDefine('HAVE_SDL_CPUINFO', 'no');
	MkSaveUndef('HAVE_SDL_CPUINFO');
}

BEGIN
{
	my $n = 'sdl_cpuinfo';

	$DESCR{$n}   = 'SDL cpuinfo functions';
	$TESTS{$n}   = \&TEST_sdl_cpuinfo;
	$DISABLE{$n} = \&DISABLE_sdl_cpuinfo;
	$DEPS{$n}    = 'cc,sdl';
}
;1
