# vim:ts=4
# Public domain

sub Test_Cocoa
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
	MkSaveIfTrue('${HAVE_COCOA}', 'COCOA_CFLAGS', 'COCOA_LIBS');
	return (0);
}

sub Disable_Cocoa
{
	MkDefine('HAVE_COCOA', 'no');
	MkDefine('COCOA_CFLAGS', '');
	MkDefine('COCOA_LIBS', '');
	
	MkSaveUndef('HAVE_COCOA', 'COCOA_CFLAGS', 'COCOA_LIBS');
}

sub Emul
{
	Disable_Cocoa();
	return (1);
}

BEGIN
{
	my $n = 'cocoa';

	$DESCR{$n} = 'the Cocoa framework';
	$URL{$n}   = 'http://developer.apple.com';
	$DEPS{$n}  = 'objc';

	$TESTS{$n}   = \&Test_Cocoa;
	$DISABLE{$n} = \&Disable_Cocoa;
	$EMUL{$n}    = \&Emul;
}

;1
