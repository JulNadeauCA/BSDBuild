# vim:ts=4
# Public domain

sub TEST_dyld
{
	BeginTestHeaders();
	DetectHeaderC('HAVE_MACH_O_DYLD_H',	'<mach-o/dyld.h>');

	TryCompile 'HAVE_DYLD', << 'EOF';
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

	MkIfTrue('${HAVE_DYLD}');
		MkPrintS('checking for NSLINKMODULE_OPTION_RETURN_ON_ERROR');
		TryCompile 'HAVE_DYLD_RETURN_ON_ERROR', << 'EOF';
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
	MkElse;
		MkDefine('HAVE_DYLD_RETURN_ON_ERROR', 'no');
		MkSaveUndef('HAVE_DYLD_RETURN_ON_ERROR');
	MkEndif;

	EndTestHeaders();
}

sub DISABLE_dyld
{
	MkDefine('HAVE_DYLD', 'no');
	MkDefine('HAVE_MACH_O_DYLD_H', 'no');
	MkDefine('HAVE_DYLD_RETURN_ON_ERROR', 'no');
	MkSaveUndef('HAVE_DYLD', 'HAVE_MACH_O_DYLD_H', 'HAVE_DYLD_RETURN_ON_ERROR');
}

BEGIN
{
	my $n = 'dyld';

	$DESCR{$n}   = 'dyld interface';
	$TESTS{$n}   = \&TEST_dyld;
	$DISABLE{$n} = \&DISABLE_dyld;
	$DEPS{$n}    = 'cc';
}
;1
