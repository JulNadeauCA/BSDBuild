# Public domain

my $testCode = << 'EOF';
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

int main(int argc, char *argv[])
{
	lua_State *ls = luaL_newstate();
	luaL_openlibs(ls);
	luaL_dofile(ls, "script.lua");
	return (0);
}
EOF

sub TEST_lua
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'lua-5.4', '--modversion', 'LUA_VERSION');
	MkIfFound($pfx, $ver, 'LUA_VERSION');
		MkExecPkgConfig($pfx, 'lua-5.4', '--cflags', 'LUA_CFLAGS');
		MkExecPkgConfig($pfx, 'lua-5.4', '--libs', 'LUA_LIBS');

		MkPrintSN('checking whether lua-5.4 works...');
		MkCompileC('HAVE_LUA', '${LUA_CFLAGS}', '${LUA_LIBS}', $testCode);
		MkIfFalse('${HAVE_LUA}');
			MkDisableFailed('lua');
		MkEndif;
	MkElse;
		MkExecPkgConfig($pfx, 'lua-5.3', '--modversion', 'LUA_VERSION');
		MkIfFound($pfx, $ver, 'LUA_VERSION');
			MkExecPkgConfig($pfx, 'lua-5.3', '--cflags', 'LUA_CFLAGS');
			MkExecPkgConfig($pfx, 'lua-5.3', '--libs', 'LUA_LIBS');

			MkPrintSN('checking whether lua-5.3 works...');
			MkCompileC('HAVE_LUA', '${LUA_CFLAGS}', '${LUA_LIBS}', $testCode);
			MkIfFalse('${HAVE_LUA}');
				MkDisableFailed('lua');
			MkEndif;
		MkElse;
			MkExecPkgConfig($pfx, 'lua', '--modversion', 'LUA_VERSION');
			MkIfFound($pfx, $ver, 'LUA_VERSION');
				MkExecPkgConfig($pfx, 'lua', '--cflags', 'LUA_CFLAGS');
				MkExecPkgConfig($pfx, 'lua', '--libs', 'LUA_LIBS');

				MkPrintSN('checking whether lua works...');
				MkCompileC('HAVE_LUA', '${LUA_CFLAGS}', '${LUA_LIBS}', $testCode);
				MkIfFalse('${HAVE_LUA}');
					MkDisableFailed('lua');
				MkEndif;
			MkElse;
				MkDisableFailed('lua');
			MkEndif;
		MkEndif;
	MkEndif;
	
	MkIfTrue('${HAVE_LUA}');
		MkDefine('LUA_PC', 'lua');
	MkEndif;
}

sub CMAKE_lua
{
        return << 'EOF';
macro(Check_Lua)
	set(LUA_CFLAGS "")
	set(LUA_LIBS "")

	find_package(lua)
	if(LUA_FOUND)
		set(HAVE_LUA ON)
		BB_Save_Define(HAVE_LUA)
		if(${LUA_INCLUDE_DIRS})
			set(LUA_CFLAGS "-I${LUA_INCLUDE_DIRS}")
		endif()
		set(LUA_LIBS "${LUA_LIBRARIES}")
	else()
		set(HAVE_LUA OFF)
		BB_Save_Undef(HAVE_LUA)
	endif()

	BB_Save_MakeVar(LUA_CFLAGS "${LUA_CFLAGS}")
	BB_Save_MakeVar(LUA_LIBS "${LUA_LIBS}")
endmacro()

macro(Disable_Lua)
	set(HAVE_LUA OFF)
	BB_Save_Undef(HAVE_LUA)
	BB_Save_MakeVar(LUA_CFLAGS "")
	BB_Save_MakeVar(LUA_LIBS "")
endmacro()
EOF
}

sub DISABLE_lua
{
	MkDefine('HAVE_LUA', 'no') unless $TestFailed;
	MkDefine('LUA_CFLAGS', '');
	MkDefine('LUA_LIBS', '');
	MkSaveUndef('HAVE_LUA');
}

BEGIN
{
	my $n = 'lua';

	$DESCR{$n}   = 'lua';
	$URL{$n}     = 'https://www.lua.org/';
	$TESTS{$n}   = \&TEST_lua;
	$CMAKE{$n}   = \&CMAKE_lua;
	$DISABLE{$n} = \&DISABLE_lua;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'LUA_CFLAGS LUA_LIBS';
}
;1
