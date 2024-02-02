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

sub CMAKE_gettext
{
        return << 'EOF';
macro(Check_Gettext)
	set(GETTEXT_CFLAGS "")
	set(GETTEXT_LIBS "")

	include(FindIntl)
	if(Intl_FOUND)
		set(HAVE_GETTEXT ON)
		BB_Save_Define(HAVE_GETTEXT)
		if(${Intl_INCLUDE_DIRS})
			set(GETTEXT_CFLAGS "-I${Intl_INCLUDE_DIRS}")
		endif()
		set(GETTEXT_LIBS "${Intl_LIBRARIES}")
	else()
		set(HAVE_GETTEXT OFF)
		BB_Save_Undef(HAVE_GETTEXT)
	endif()
	
	BB_Save_MakeVar(GETTEXT_CFLAGS "${GETTEXT_CFLAGS}")
	BB_Save_MakeVar(GETTEXT_LIBS "${GETTEXT_LIBS}")
endmacro()

macro(Disable_Gettext)
	set(HAVE_GETTEXT OFF)
	BB_Save_Undef(HAVE_GETTEXT)
	BB_Save_MakeVar(GETTEXT_CFLAGS "")
	BB_Save_MakeVar(GETTEXT_LIBS "")
endmacro()
EOF
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
	$CMAKE{$n}   = \&CMAKE_gettext;
	$DISABLE{$n} = \&DISABLE_gettext;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'GETTEXT_CFLAGS GETTEXT_LIBS';
}
;1
