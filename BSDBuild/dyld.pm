# Public domain

my $testCode = << 'EOF';
#ifdef __APPLE__
# include <Availability.h>
# ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
#  if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
#   error "deprecated in Leopard and later"
#  endif
# endif
#endif

#ifdef HAVE_MACH_O_DYLD_H
#include <mach-o/dyld.h>
#endif

int
main(int argc, char *argv[])
{
	NSObjectFileImage img;
	NSObjectFileImageReturnCode rv;

	rv = NSCreateObjectFileImageFromFile("foo", &img);
	return (rv == NSObjectFileImageSuccess);
}
EOF

my $testCodeDyldReturnOnError = << 'EOF';
#ifdef HAVE_MACH_O_DYLD_H
#include <mach-o/dyld.h>
#endif
int
main(int argc, char *argv[])
{
	NSObjectFileImage img;
	NSObjectFileImageReturnCode rv;
	void *handle;

	rv = NSCreateObjectFileImageFromFile("foo", &img);
	handle = (void *)NSLinkModule(img, "foo",
	    NSLINKMODULE_OPTION_RETURN_ON_ERROR|
		NSLINKMODULE_OPTION_NONE);
	if (handle == NULL) {
		NSLinkEditErrors errs;
		int n;
		const char *f, *s = NULL;
		NSLinkEditError(&errs, &n, &f, &s);
	}
	return (0);
}
EOF

sub TEST_dyld
{
	BeginTestHeaders();
	DetectHeaderC('HAVE_MACH_O_DYLD_H', '<mach-o/dyld.h>');

	TryCompile('HAVE_DYLD', $testCode);
	MkIfTrue('${HAVE_DYLD}');
		MkPrintSN('checking for NSLINKMODULE_OPTION_RETURN_ON_ERROR');
		TryCompile('HAVE_DYLD_RETURN_ON_ERROR', $testCodeDyldReturnOnError);
	MkElse;
		MkDisableFailed('dyld');
	MkEndif;

	EndTestHeaders();
}

sub CMAKE_dyld
{
	my $code = MkCodeCMAKE($testCode);
	my $codeDyldReturnOnError = MkCodeCMAKE($testCodeDyldReturnOnError);

	return << "EOF";
macro(Check_Dyld)
	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})

	CHECK_INCLUDE_FILE(mach-o/dyld.h HAVE_MACH_O_DYLD_H)
	if(HAVE_MACH_O_DYLD_H)
		set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -DHAVE_MACH_O_DYLD_H")
		BB_Save_Define(HAVE_MACH_O_DYLD_H)
	else()
		BB_Save_Undef(HAVE_MACH_O_DYLD_H)
	endif()

	check_c_source_compiles("
$code" HAVE_DYLD)
	if (HAVE_DYLD)
		BB_Save_Define(HAVE_DYLD)

		check_c_source_compiles("
$codeDyldReturnOnError" HAVE_DYLD_RETURN_ON_ERROR)
		if(HAVE_DYLD_RETURN_ON_ERROR)
			BB_Save_Define(HAVE_DYLD_RETURN_ON_ERROR)
		else()
			BB_Save_Undef(HAVE_DYLD_RETURN_ON_ERROR)
		endif()
	else()
		BB_Save_Undef(HAVE_DYLD)
		BB_Save_Undef(HAVE_DYLD_RETURN_ON_ERROR)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
endmacro()

macro(Disable_Dyld)
	BB_Save_Undef(HAVE_DYLD)
	BB_Save_Undef(HAVE_MACH_O_DYLD_H)
	BB_Save_Undef(HAVE_DYLD_RETURN_ON_ERROR)
endmacro()
EOF
}

sub DISABLE_dyld
{
	MkDefine('HAVE_DYLD', 'no') unless $TestFailed;
	MkDefine('HAVE_MACH_O_DYLD_H', 'no');
	MkDefine('HAVE_DYLD_RETURN_ON_ERROR', 'no');
	MkSaveUndef('HAVE_DYLD', 'HAVE_MACH_O_DYLD_H', 'HAVE_DYLD_RETURN_ON_ERROR');
}

BEGIN
{
	my $n = 'dyld';

	$DESCR{$n}   = 'dyld interface';
	$TESTS{$n}   = \&TEST_dyld;
	$CMAKE{$n}   = \&CMAKE_dyld;
	$DISABLE{$n} = \&DISABLE_dyld;
	$DEPS{$n}    = 'cc';
}
;1
