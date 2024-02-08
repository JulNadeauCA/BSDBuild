# Public domain

my $testCode = << 'EOF';
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) { return (0); }
EOF

my $testCflags = '-DTARGET_API_MAC_CARBON ' .
                 '-DTARGET_API_MAC_OSX ' .
                 '-force_cpusubtype_ALL -fpascal-strings';

my $testLibs = '-lobjc '.
               '-Wl,-framework,Cocoa ' .
               '-Wl,-framework,OpenGL ' .
               '-Wl,-framework,IOKit';

sub TEST_cocoa
{
	my ($ver, $pfx) = @_;
	
	MkDefine('COCOA_CFLAGS', $testCflags);
	MkDefine('COCOA_LIBS', $testLibs);

	MkCompileOBJC('HAVE_COCOA', '${COCOA_CFLAGS}', '${COCOA_LIBS}', $testCode);
	MkIfFalse('${HAVE_COCOA}');
		MkDisableFailed('cocoa');
	MkEndif;
}

sub CMAKE_cocoa
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Cocoa)
	set(COCOA_CFLAGS "$testCflags")
	set(COCOA_LIBS "$testLibs")

	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} \${COCOA_CFLAGS}")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} \${COCOA_LIBS}")
		
	check_objc_source_compiles("
$code" HAVE_COCOA)
	if (HAVE_COCOA)
		BB_Save_Define(HAVE_COCOA)
	else()
		set(COCOA_CFLAGS "")
		set(COCOA_LIBS "")
		BB_Save_Undef(HAVE_COCOA)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})

	BB_Save_MakeVar(COCOA_CFLAGS "\${COCOA_CFLAGS}")
	BB_Save_MakeVar(COCOA_LIBS "\${COCOA_LIBS}")
endmacro()

macro(Disable_Cocoa)
	set(HAVE_COCOA OFF)
	BB_Save_Undef(HAVE_COCOA)
	BB_Save_MakeVar(COCOA_CFLAGS "")
	BB_Save_MakeVar(COCOA_LIBS "")
endmacro()
EOF
}

sub DISABLE_cocoa
{
	MkDefine('HAVE_COCOA', 'no') unless $TestFailed;
	MkDefine('COCOA_CFLAGS', '');
	MkDefine('COCOA_LIBS', '');
	MkSaveUndef('HAVE_COCOA');
}

BEGIN
{
	my $n = 'cocoa';

	$DESCR{$n}   = 'the Cocoa framework';
	$URL{$n}     = 'http://developer.apple.com';
	$TESTS{$n}   = \&TEST_cocoa;
	$CMAKE{$n}   = \&CMAKE_cocoa;
	$DISABLE{$n} = \&DISABLE_cocoa;
	$DEPS{$n}    = 'objc';
	$SAVED{$n}   = 'COCOA_CFLAGS COCOA_LIBS';
}
;1
