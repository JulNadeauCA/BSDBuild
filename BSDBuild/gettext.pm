# Public domain

my @autoPrefixDirs = (
	'/usr',
	'/usr/local',
	'/opt',
	'/opt/local',
	'/usr/pkg'
);
my $testCode = << "EOF";
#include <libintl.h>
int main(int argc, char *argv[])
{
	char *s;
	bindtextdomain("foo", "/foo");
	textdomain("foo");
	s = gettext("string");
	s = dgettext("foo","string");
	return (s != NULL);
}
EOF

sub TEST_gettext
{
	my ($ver, $pfx) = @_;

	MkDefine('GETTEXT_CFLAGS', '');
	MkDefine('GETTEXT_LIBS', '');

	MkCompileC('HAVE_GETTEXT', '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}', $testCode);
	MkIfFalse('${HAVE_GETTEXT}');
		MkPrintSN('checking for a gettext library in -lintl...');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/libintl.h");
			    MkDefine('GETTEXT_CFLAGS', "-I$pfx/include");
			    MkDefine('GETTEXT_LIBS', "-L$pfx/lib -lintl");
			MkEndif;
		MkElse;
			foreach my $dir ($pfx, @autoPrefixDirs) {
				MkIfExists("$dir/include/libintl.h");
				    MkDefine('GETTEXT_CFLAGS', "-I$dir/include");
				    MkDefine('GETTEXT_LIBS', "-L$dir/lib -lintl");
				MkEndif;
			}
		MkEndif;

		MkCompileC('HAVE_GETTEXT', '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}', $testCode);
		MkIfFalse('${HAVE_GETTEXT}');
			MkPrintSN('checking whether -lintl requires -liconv...');
			MkIfNE($pfx, '');
				MkIfExists("$pfx/include/iconv.h");
				    MkDefine('GETTEXT_CFLAGS', "\${GETTEXT_CFLAGS} -I$pfx/include");
				    MkDefine('GETTEXT_LIBS', "\${GETTEXT_LIBS} -L$pfx/lib -liconv");
				MkEndif;
			MkElse;
				foreach my $dir ($pfx, @autoPrefixDirs) {
					MkIfExists("$dir/include/iconv.h");
					    MkDefine('GETTEXT_CFLAGS', "\${GETTEXT_CFLAGS} -I$dir/include");
					    MkDefine('GETTEXT_LIBS', "\${GETTEXT_LIBS} -L$dir/lib -liconv");
					MkEndif;
				}
			MkEndif;
			MkCompileC('HAVE_GETTEXT',
			           '${GETTEXT_CFLAGS}', '${GETTEXT_LIBS}',
			           $testCode);
			MkIfFalse('${HAVE_GETTEXT}');
				MkDisableFailed('gettext');
			MkEndif;
		MkEndif;
	MkEndif;
}

sub DISABLE_gettext
{
	MkDefine('HAVE_GETTEXT', 'no') unless $TestFailed;
	MkDefine('GETTEXT_CFLAGS', '');
	MkDefine('GETTEXT_LIBS', '');
	MkSaveUndef('HAVE_GETTEXT');
}

BEGIN
{
	my $n = 'gettext';

	$DESCR{$n}   = 'a gettext library in libc';
	$TESTS{$n}   = \&TEST_gettext;
	$DISABLE{$n} = \&DISABLE_gettext;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'GETTEXT_CFLAGS GETTEXT_LIBS';
}
;1
