# Public domain

my $testCode = << 'EOF';
#include <string.h>
#ifdef HAVE_DLFCN_H
#include <dlfcn.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	char *error;
	handle = dlopen("foo.so", 0);
	error = dlerror();
	(void)dlsym(handle, "foo");
	return (error != NULL);
}
EOF

sub TEST_dlopen
{
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_DLFCN_H', '<dlfcn.h>');
	TryCompile('HAVE_DLOPEN', $testCode);
	MkIfFalse('${HAVE_DLOPEN}');
		MkPrintSN('checking for dlopen() in -ldl...');
		TryCompileFlagsC('HAVE_DLOPEN', '-ldl', $testCode);
		MkIfTrue('${HAVE_DLOPEN}');
			MkDefine('DSO_CFLAGS', '');
			MkDefine('DSO_LIBS', '-ldl');
		MkElse;
			MkDisableFailed('dlopen');
		MkEndif;
	MkEndif;
	EndTestHeaders();
}

sub CMAKE_dlopen
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Dlopen)
	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(DSO_CFLAGS "")
	set(DSO_LIBS "")

	CHECK_INCLUDE_FILE(dlfcn.h HAVE_DLFCN_H)

	if(HAVE_DLFCN_H)
		set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -DHAVE_DLFCN_H")
		BB_Save_Define(HAVE_DLFCN_H)
	else()
		BB_Save_Undef(HAVE_DLFCN_H)
	endif()

	check_c_source_compiles("
$code" HAVE_DLOPEN)
	if(HAVE_DLOPEN)
		BB_Save_Define(HAVE_DLOPEN)
	else()
		check_library_exists(dl dlopen "" HAVE_LIBDL_DLOPEN)
		if(HAVE_LIBDL_DLOPEN)
			set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -ldl")
			check_c_source_compiles("
$code" HAVE_DLOPEN_IN_LIBDL)
			if(HAVE_DLOPEN_IN_LIBDL)
				BB_Save_Define(HAVE_DLOPEN)
				set(DSO_LIBS "-ldl")
			else()
				BB_Save_Undef(HAVE_DLOPEN)
			endif()
		else()
			BB_Save_Undef(HAVE_DLOPEN)
		endif()
	endif()

	BB_Save_MakeVar(DSO_CFLAGS "\${DSO_CFLAGS}")
	BB_Save_MakeVar(DSO_LIBS "\${DSO_LIBS}")

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Dlopen)
	BB_Save_Undef(HAVE_DLOPEN)
	BB_Save_Undef(HAVE_DLFCN_H)
endmacro()
EOF
}

sub DISABLE_dlopen
{
	MkDefine('HAVE_DLOPEN', 'no') unless $TestFailed;
	MkDefine('HAVE_DLFCN_H', 'no');
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');
	MkSaveUndef('HAVE_DLOPEN', 'HAVE_DLFCN_H');
}

BEGIN
{
	my $n = 'dlopen';

	$DESCR{$n}   = 'dlopen() interface';
	$TESTS{$n}   = \&TEST_dlopen;
	$CMAKE{$n}   = \&CMAKE_dlopen;
	$DISABLE{$n} = \&DISABLE_dlopen;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DSO_CFLAGS DSO_LIBS';
}
;1
