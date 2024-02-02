# Public domain

my $testCode = << 'EOF';
#include <string.h>
#ifdef HAVE_DL_H
#include <dl.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	void **p;

	handle = shl_load("foo.so", BIND_IMMEDIATE, 0);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_PROCEDURE, p);
	(void)shl_findsym((shl_t *)&handle, "foo", TYPE_DATA, p);
	shl_unload((shl_t)handle);
	return (handle != NULL);
}
EOF

sub TEST_shl_load
{
	my ($ver, $pfx) = @_;

	BeginTestHeaders();
	DetectHeaderC('HAVE_DL_H', '<dl.h>');

	MkIfNE($pfx, '');
		MkDefine('SHL_LOAD_LIBS', "-L$pfx -ldld");
	MkElse;
		MkDefine('SHL_LOAD_LIBS', '-ldld');
	MkEndif;

	TryCompileFlagsC('HAVE_SHL_LOAD', '${SHL_LOAD_LIBS}', $testCode);
	MkIfTrue('${HAVE_SHL_LOAD}');
		MkDefine('DSO_LIBS', '$DSO_LIBS $SHL_LOAD_LIBS');
		MkSaveDefine('HAVE_SHL_LOAD');
	MkElse;
		MkDisableFailed('shl_load');
	MkEndif;

	EndTestHeaders();
}

sub CMAKE_shl_load
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Shl_load)
	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(SHL_LOAD_LIBS "-ldld")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} \${SHL_LOAD_LIBS}")

	CHECK_INCLUDE_FILE(dl.h HAVE_DL_H)
	if(HAVE_DL_H)
		set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -DHAVE_DL_H")
		BB_Save_Define(HAVE_DL_H)
	else()
		BB_Save_Undef(HAVE_DL_H)
	endif()

	check_c_source_compiles("
$code" HAVE_SHL_LOAD)
	if(HAVE_SHL_LOAD)
		BB_Save_Define(HAVE_SHL_LOAD)

		set(DSO_LIBS "\${DSO_LIBS} \${SHL_LOAD_LIBS}")
		BB_Save_MakeVar(DSO_LIBS "\${DSO_LIBS}")
	else()
		BB_Save_Undef(HAVE_SHL_LOAD)
	endif()

	BB_Save_MakeVar(SHL_LOAD_LIBS "\${SHL_LOAD_LIBS}")

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Shl_load)
	BB_Save_Undef(HAVE_SHL_LOAD)
	BB_Save_Undef(HAVE_DL_H)
	BB_Save_MakeVar(SHL_LOAD_LIBS "")
endmacro()
EOF
}

sub DISABLE_shl_load
{
	MkDefine('HAVE_SHL_LOAD', 'no') unless $TestFailed;
	MkDefine('HAVE_DL_H', 'no');
	MkDefine('SHL_LOAD_LIBS', '');
	MkSaveUndef('HAVE_SHL_LOAD', 'HAVE_DL_H');
}

BEGIN
{
	my $n = 'shl_load';

	$DESCR{$n}   = 'the shl_load() interface';
	$TESTS{$n}   = \&TEST_shl_load;
	$CMAKE{$n}   = \&CMAKE_shl_load;
	$DISABLE{$n} = \&DISABLE_shl_load;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DSO_LIBS SHL_LOAD_LIBS';
}
;1
