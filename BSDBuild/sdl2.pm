# Public domain

my $testCode = << 'EOF';
#ifdef _USE_SDL_FRAMEWORK
# include <SDL.h>
# ifdef main
#  undef main
# endif
#else
# include <SDL.h>
#endif
int main(int argc, char *argv[]) {
	SDL_Surface *su;

	if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE) != 0) {
		return (1);
	}
	su = SDL_CreateRGBSurface(0, 16, 16, 32, 0, 0, 0, 0);
	SDL_FreeSurface(su);
	SDL_Quit();
	return (0);
}
EOF

sub TEST_sdl2
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkExecOutputPfx($pfx, 'sdl2-config', '--prefix', 'SDL2_PREFIX');
		MkExecOutputPfx($pfx, 'sdl2-config', '--version', 'SDL2_VERSION');
		MkExecOutputPfx($pfx, 'sdl2-config', '--cflags', 'SDL2_CFLAGS');
		MkExecOutputPfx($pfx, 'sdl2-config', '--libs', 'SDL2_LIBS');
	MkElse;
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkExecOutput('sdl2-config', '--version', 'SDL2_VERSION');
			MkIfNE('${SDL2_VERSION}', '');
				MkExecOutput('sdl2-config', '--prefix', 'SDL2_PREFIX');
				MkExecOutput('sdl2-config', '--cflags', 'SDL2_CFLAGS');
				MkExecOutput('sdl2-config', '--libs', 'SDL2_LIBS');
			MkElse;
				MkPrintSN('framework...');
				MkDefine('SDL2_VERSION', '2.0.0');
				MkDefine('SDL2_CFLAGS', '-D_USE_SDL_FRAMEWORK');
				MkDefine('SDL2_LIBS', '-framework SDL2');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*');
			MkExecOutput('sdl2-config', '--prefix', 'SDL2_PREFIX');
			MkExecOutput('sdl2-config', '--version', 'SDL2_VERSION');
			MkExecOutput('sdl2-config', '--cflags', 'SDL2_CFLAGS');
			MkExecOutput('sdl2-config', '--libs', 'SDL2_LIBS');
			MkCaseEnd;
		MkEsac;
	MkEndif;
		
	MkIfFound($pfx, $ver, 'SDL2_VERSION');
		MkPrintSN('checking whether SDL2 works...');
		MkCompileC('HAVE_SDL2',
		           '${SDL2_CFLAGS}', '${SDL2_LIBS}', $testCode);
		MkIfTrue('${HAVE_SDL2}');
			MkCaseIn('${host}');
			MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
				#
				# On Cygwin/MinGW, linking against -lSDL2.dll is preferable 
				# to the output of `sdl2-config`; use it if available.
				#
				MkIfExists('${SDL2_PREFIX}/include/SDL2');
					MkDefine('SDL2_CFLAGS', '-I${SDL2_PREFIX}/include/SDL2 -D_GNU_SOURCE=1');
				MkEndif;
				MkIfExists('${SDL2_PREFIX}/lib/libSDL2.dll.a');
					MkDefine('SDL2_LIBS', '-L${SDL2_PREFIX}/lib -lSDL2.dll');
				MkEndif;
				MkCaseEnd;
			MkEsac;

			MkPushIFS('" "');
			MkDefine('SDL2_LIBS_FIXED', '');
			MkFor('sdl2_lib', '$SDL2_LIBS');
			    MkCaseIn('${sdl2_lib}');
				MkCaseBegin('-Wl*');
					MkCaseEnd;
				MkCaseBegin('-pthread');
					MkDefine('SDL2_LIBS_FIXED', '$SDL2_LIBS_FIXED -lpthread');
					MkCaseEnd;
				MkCaseBegin('*');
					MkDefine('SDL2_LIBS_FIXED', '$SDL2_LIBS_FIXED ${sdl2_lib}');
					MkCaseEnd;
				MkEsac;
			MkDone;
			MkPopIFS();

			MkDefine('SDL2_LIBS', '${SDL2_LIBS_FIXED}');
		MkElse;
			MkPrintSN('checking whether SDL2 works (with X11 libs)...');
			MkAppend('SDL2_LIBS', '-L/usr/X11R6/lib -lX11 -lXext -lXrandr '.
			                      '-lXrender');
			MkCompileC('HAVE_SDL2',
			           '${SDL2_CFLAGS}', '${SDL2_LIBS}', $testCode);
			MkIfFalse('${HAVE_SDL2}');
				MkDisableFailed('sdl2');
			MkEndif;
		MkEndif;
	MkElse;
		MkDisableNotFound('sdl2');
	MkEndif;

	MkIfTrue('${HAVE_SDL2}');
		MkDefine('SDL2_PC', 'sdl2');
	MkEndif;
}

sub CMAKE_sdl2
{
        return << 'EOF';
macro(Check_Sdl2)
	set(SDL2_CFLAGS "")
	set(SDL2_LIBS "")

	find_package(SDL2)
	if(SDL2_FOUND)
		set(HAVE_SDL2 ON)

		foreach(sdl2incdir ${SDL2_INCLUDE_DIRS})
			list(APPEND SDL2_CFLAGS "-I${sdl2incdir}")
		endforeach()

		find_library(SDL2_LIBRARY NAMES SDL2)
		if(SDL2_LIBRARY)
			list(APPEND SDL2_LIBS "${SDL2_LIBRARY}")
		endif()

		message(STATUS "Found SDL2: ${SDL2_LIBS} (found version \"${SDL2_VERSION}\")")
		BB_Save_Define(HAVE_SDL2)
	else()
		set(HAVE_SDL2 OFF)
		BB_Save_Undef(HAVE_SDL2)
	endif()

	BB_Save_MakeVar(SDL2_CFLAGS "${SDL2_CFLAGS}")
	BB_Save_MakeVar(SDL2_LIBS "${SDL2_LIBS}")
endmacro()

macro(Disable_Sdl2)
	set(HAVE_SDL2 OFF)
	BB_Save_Undef(HAVE_SDL2)
	BB_Save_MakeVar(SDL2_CFLAGS "")
	BB_Save_MakeVar(SDL2_LIBS "")
endmacro()
EOF
}

sub DISABLE_sdl2
{
	MkDefine('HAVE_SDL2', 'no') unless $TestFailed;
	MkDefine('SDL2_CFLAGS', '');
	MkDefine('SDL2_LIBS', '');
	MkSaveUndef('HAVE_SDL2');
}

BEGIN
{
	my $n = 'sdl2';

	$DESCR{$n}   = 'SDL 2.0';
	$URL{$n}     = 'http://www.libsdl.org';
	$TESTS{$n}   = \&TEST_sdl2;
	$CMAKE{$n}   = \&CMAKE_sdl2;
	$DISABLE{$n} = \&DISABLE_sdl2;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'SDL2_CFLAGS SDL2_LIBS SDL2_PC';
}
;1
