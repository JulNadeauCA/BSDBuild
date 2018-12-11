# vim:ts=4
# Public domain

sub TEST_getopt
{
	TryCompile 'HAVE_GETOPT', << 'EOF';
#include <string.h>
#include <getopt.h>

int
main(int argc, char *argv[])
{
	int c, x = 0;
	while ((c = getopt(argc, argv, "foo")) != -1) {
		extern char *optarg;
		extern int optind, opterr, optopt;
		if (optarg != NULL) { x = 1; }
		if (optind > 0) { x = 2; }
		if (opterr > 0) { x = 3; }
		if (optopt > 0) { x = 4; }
	}
	return (x != 0);
}
EOF
}

sub DISABLE_getopt
{
	MkDefine('HAVE_GETOPT', 'no');
	MkSaveUndef('HAVE_GETOPT');
}

BEGIN
{
	my $n = 'getopt';

	$DESCR{$n}   = 'the getopt() function';
	$TESTS{$n}   = \&TEST_getopt;
	$DISABLE{$n} = \&DISABLE_getopt;
	$DEPS{$n}    = 'cc';
}
;1
