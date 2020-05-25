# vim:ts=4
# Public domain

sub TEST_cocoa
{
	my ($ver, $pfx) = @_;
	
	MkDefine('COCOA_CFLAGS', '-DTARGET_API_MAC_CARBON ' .
	                         '-DTARGET_API_MAC_OSX ' .
	                         '-force_cpusubtype_ALL -fpascal-strings');
	MkDefine('COCOA_LIBS', '-lobjc '.
	                       '-Wl,-framework,Cocoa ' .
	                       '-Wl,-framework,OpenGL ' .
	                       '-Wl,-framework,IOKit');

	MkCompileOBJC('HAVE_COCOA', '${COCOA_CFLAGS}', '${COCOA_LIBS}', << 'EOF');
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) { return (0); }
EOF
	MkSave('COCOA_CFLAGS', 'COCOA_LIBS');
}

sub DISABLE_cocoa
{
	MkDefine('HAVE_COCOA', 'no');
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
	$DISABLE{$n} = \&DISABLE_cocoa;
	$DEPS{$n}    = 'objc';
}
;1
