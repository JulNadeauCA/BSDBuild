# Public domain

my $testCode = << 'EOF';
#include <Cg/cg.h>
#include <Cg/cgGL.h>

CGcontext context;
CGeffect effect;
CGtechnique technique;

int main(int argc, char *argv[]) {
	context = cgCreateContext();
	return (0);
}
EOF
my @autoIncludeDirs = (
	'/usr/include',
	'/usr/local/include',
	'/usr/Cg/include',
	'/usr/local/Cg/include',
	'/usr/X11R6/include',
	'/usr/X11R6/Cg/include',
);

sub TEST_cg
{
	my ($ver, $pfx) = @_;

	MkDefine('CG_CFLAGS', '');
	MkDefine('CG_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('CG_CFLAGS', "-I$pfx/include");
		MkDefine('CG_LIBS', "-L$pfx/lib -lCgGL -lCg -lstdc++");
	MkElse;
		foreach my $dir (@autoIncludeDirs) {
			MkIfExists("$dir/Cg");
				MkDefine('CG_CFLAGS', "\${CG_CFLAGS} -I$dir");
			MkEndif;
		}
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkDefine('CG_LIBS', "-F/System/Library/Frameworks -framework Cg");
			MkCaseEnd();
		MkCaseBegin('x86_64-*-linux*');
			MkDefine('CG_LIBS', "-L/usr/X11R6/lib64 -L/usr/lib64 -lCgGL -lCg -lstdc++");
			MkCaseEnd();
		MkCaseBegin('*-*-linux*');
			MkDefine('CG_LIBS', "-L/usr/X11R6/lib -lCgGL -lCg -lstdc++");
			MkCaseEnd();
		MkCaseBegin('*');
			MkDefine('CG_LIBS', "-lCgGL -lCg -lstdc++");
			MkCaseEnd();
		MkEsac;
	MkEndif;

	MkCompileC('HAVE_CG',
	           '${CG_CFLAGS} ${OPENGL_CFLAGS} ${PTHREADS_CFLAGS}',
	           '${CG_LIBS} ${OPENGL_LIBS} ${PTHREADS_LIBS}',
	           $testCode);
	MkIfFalse('${HAVE_CG}');
		MkDisableFailed('cg');
	MkEndif;
}

sub DISABLE_cg
{
	MkDefine('HAVE_CG', 'no') unless $TestFailed;
	MkDefine('CG_CFLAGS', '');
	MkDefine('CG_LIBS', '');
	MkSaveUndef('HAVE_CG');
}

BEGIN
{
	my $n = 'cg';

	$DESCR{$n}   = 'Cg';
	$URL{$n}     = 'http://developer.nvidia.com/object/cg_toolkit.html';
	$TESTS{$n}   = \&TEST_cg;
	$DISABLE{$n} = \&DISABLE_cg;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CG_CFLAGS CG_LIBS';
}
;1
