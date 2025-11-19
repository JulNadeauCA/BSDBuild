# Public domain

my $testCode = << 'EOF';
#include <plutosvg.h>
#include <stdio.h>

int main() {
	plutosvg_document_t *doc = plutosvg_document_load_from_file("x.svg", -1, -1);
	plutovg_surface_t *s = plutosvg_document_render_to_surface(doc, NULL, -1, -1, NULL, NULL, NULL);
	plutovg_surface_write_to_png(s, "x.png");
	plutosvg_document_destroy(doc);
	plutovg_surface_destroy(s);
	return 0;
}
EOF

sub TEST_plutosvg
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'plutosvg', '--modversion', 'PLUTOSVG_VERSION');
	MkExecPkgConfig($pfx, 'plutosvg', '--cflags', 'PLUTOSVG_CFLAGS');
	MkExecPkgConfig($pfx, 'plutosvg', '--libs', 'PLUTOSVG_LIBS');

	MkExecPkgConfig($pfx, 'plutovg', '--modversion', 'PLUTOVG_VERSION');
	MkExecPkgConfig($pfx, 'plutovg', '--cflags', 'PLUTOVG_CFLAGS');
	MkExecPkgConfig($pfx, 'plutovg', '--libs', 'PLUTOVG_LIBS');

	MkIfFound($pfx, $ver, 'PLUTOSVG_VERSION');
		MkPrintSN('checking whether PlutoSVG and PlutoVG works...');
		MkCompileC('HAVE_PLUTOSVG', '${PLUTOSVG_CFLAGS} ${PLUTOVG_CFLAGS}', '${PLUTOSVG_LIBS} ${PLUTOVG_LIBS}', $testCode);
		MkIfTrue('${HAVE_PLUTOSVG}');
			MkDefine('HAVE_PLUTOVG', 'yes');
		MkElse;
			MkDisableFailed('plutosvg');
			MkDisableFailed('plutovg');
		MkEndif;
	MkElse;
		MkDisableNotFound('plutosvg');
		MkDisableNotFound('plutovg');
	MkEndif;
}

sub CMAKE_plutosvg
{
        return << 'EOF';
macro(Check_PlutoSVG)
	set(PLUTOSVG_CFLAGS "")
	set(PLUTOSVG_LIBS "")
	set(PLUTOVG_CFLAGS "")
	set(PLUTOVG_LIBS "")

	find_package(plutosvg)
	find_package(plutovg)
	if(plutosvg_FOUND AND plutovg_FOUND)
		set(HAVE_PLUTOSVG ON)
		set(HAVE_PLUTOVG ON)
		foreach(plutosvgincdir ${PLUTOSVG_INCLUDE_DIRS})
			list(APPEND PLUTOSVG_CFLAGS "-I${plutosvgincdir}")
		endforeach()
		foreach(plutovgincdir ${PLUTOVG_INCLUDE_DIRS})
			list(APPEND PLUTOVG_CFLAGS "-I${plutovgincdir}")
		endforeach()
		foreach(plutosvglib ${PLUTOSVG_LIBRARIES})
			list(APPEND PLUTOSVG_LIBS "${plutosvglib}")
		endforeach()
		foreach(plutovglib ${PLUTOVG_LIBRARIES})
			list(APPEND PLUTOVG_LIBS "${plutovglib}")
		endforeach()
		list(REMOVE_DUPLICATES PLUTOSVG_CFLAGS)
		list(REMOVE_DUPLICATES PLUTOSVG_LIBS)
		list(REMOVE_DUPLICATES PLUTOSVG_INCLUDE_DIRS)
		list(REMOVE_DUPLICATES PLUTOVG_CFLAGS)
		list(REMOVE_DUPLICATES PLUTOVG_LIBS)
		list(REMOVE_DUPLICATES PLUTOVG_INCLUDE_DIRS)
		BB_Save_Define(HAVE_PLUTOSVG)
		BB_Save_Define(HAVE_PLUTOVG)
	else()
		set(HAVE_PLUTOSVG OFF)
		set(HAVE_PLUTOVG OFF)
		BB_Save_Undef(HAVE_PLUTOSVG)
		BB_Save_Undef(HAVE_PLUTOVG)
	endif()

	BB_Save_MakeVar(PLUTOSVG_CFLAGS "${PLUTOSVG_CFLAGS}")
	BB_Save_MakeVar(PLUTOSVG_LIBS "${PLUTOSVG_LIBS}")

	BB_Save_MakeVar(PLUTOVG_CFLAGS "${PLUTOVG_CFLAGS}")
	BB_Save_MakeVar(PLUTOVG_LIBS "${PLUTOVG_LIBS}")
endmacro()

macro(Disable_PlutoSVG)
	set(HAVE_PLUTOSVG OFF)
	set(HAVE_PLUTOVG OFF)
	BB_Save_Undef(HAVE_PLUTOSVG)
	BB_Save_Undef(HAVE_PLUTOVG)
endmacro()
EOF
}

sub DISABLE_plutosvg
{
	MkDefine('HAVE_PLUTOSVG', 'no') unless $TestFailed;
	MkDefine('HAVE_PLUTOVG', 'no') unless $TestFailed;
	MkDefine('PLUTOSVG_CFLAGS', '');
	MkDefine('PLUTOSVG_LIBS', '');
	MkDefine('PLUTOVG_CFLAGS', '');
	MkDefine('PLUTOVG_LIBS', '');
	MkSaveUndef('HAVE_PLUTOSVG');
	MkSaveUndef('HAVE_PLUTOVG');
}

BEGIN
{
	my $n = 'plutosvg';

	$DESCR{$n}   = 'PlutoSVG and PlutoVG';
	$URL{$n}     = 'https://github.com/sammycage/plutosvg';
	$TESTS{$n}   = \&TEST_plutosvg;
	$CMAKE{$n}   = \&CMAKE_plutosvg;
	$DISABLE{$n} = \&DISABLE_plutosvg;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'PLUTOSVG_CFLAGS PLUTOSVG_LIBS PLUTOVG_CFLAGS PLUTOVG_LIBS';
}
;1
