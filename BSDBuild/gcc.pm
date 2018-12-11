# vim:ts=4
# Public domain

sub TEST_gcc
{
	MkCompileC('HAVE_GCC', '', '', << 'EOF');
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF

	MkPrintSN('checking whether the Objective-C compiler is GCC...');
	MkCompileOBJC('HAVE_GCC_OBJC', '', '', << 'EOF');
#import <stdio.h>
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF
	
	MkPrintSN('checking whether the C++ compiler is GCC...');
	MkCompileOBJC('HAVE_GCC_CXX', '', '', << 'EOF');
#import <stdio.h>
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF
}

sub DISABLE_gcc
{
	MkDefine('HAVE_GCC', 'no');
	MkDefine('HAVE_GCC_OBJC', 'no');
	MkDefine('HAVE_GCC_CXX', 'no');
	MkSaveUndef('HAVE_GCC', 'HAVE_GCC_OBJC', 'HAVE_GCC_CXX');
}

BEGIN
{
	my $n = 'gcc';

	$DESCR{$n}   = 'GCC';
	$TESTS{$n}   = \&TEST_gcc;
	$DISABLE{$n} = \&DISABLE_gcc;
}
;1
