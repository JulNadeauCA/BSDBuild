# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <tcl.h>
int sample_command(ClientData Data, Tcl_Interp *interp, int argc, Tcl_Obj *CONST argv[]) {
		int x;
		if (Tcl_GetIntFromObj(interp, (Tcl_Obj*) argv[1], &x) != TCL_OK) { return TCL_ERROR; }

		Tcl_SetIntObj(Tcl_GetObjResult(interp), 2 * x);
		return TCL_OK;
}

int main (int argc, char *argv[]) {
		int x;

		Tcl_Interp *myinterp = Tcl_CreateInterp();

		Tcl_CreateObjCommand(myinterp, "sample_command", sample_command, (ClientData) NULL, (Tcl_CmdDeleteProc*) NULL);

		if (Tcl_Eval(myinterp, "sample_command 5") != TCL_OK) { return 1; }

		if (Tcl_GetIntFromObj(myinterp, Tcl_GetObjResult(myinterp), &x) != TCL_OK) { return 2; }

		if (x != 10) { return 3; }

		return(0);

}
EOF

sub TEST_tcl
{
	my ($ver, $pfx) = @_;
	my @pcMods;

	if    ($ver =~ /^8\.7/) { @pcMods = ('tcl87', 'tcl', 'tcl86', 'tcl85'); }
	elsif ($ver =~ /^8\.6/) { @pcMods = ('tcl86', 'tcl', 'tcl87', 'tcl85'); }
	elsif ($ver =~ /^8\.5/) { @pcMods = ('tcl85', 'tcl', 'tcl86', 'tcl87'); }
	else                    { @pcMods = ('tcl', 'tcl87', 'tcl86', 'tcl85'); }

	foreach my $pcm (@pcMods) {
		MkIfPkgConfig($pcm);
			MkExecPkgConfig($pfx, $pcm, '--modversion', 'TCL_VERSION');
			MkExecPkgConfig($pfx, $pcm, '--cflags', 'TCL_CFLAGS');
			MkExecPkgConfig($pfx, $pcm, '--libs', 'TCL_LIBS');
		MkEndif;
	}

	MkIfFound($pfx, $ver, 'TCL_VERSION');
		MkPrintN('checking whether TCL works...');
		MkCompileC('HAVE_TCL', '${TCL_CFLAGS}', '${TCL_LIBS}', $testCode);
		MkSave('TCL_CFLAGS', 'TCL_LIBS');
	MkElse;
		DISABLE_tcl();
	MkEndif;
	
}

sub DISABLE_tcl
{
	MkDefine('HAVE_TCL', 'no');
	MkDefine('TCL_CFLAGS', '');
	MkDefine('TCL_LIBS', '');
	MkSaveUndef('HAVE_TCL');
}

BEGIN
{
	my $n = 'tcl';

	$DESCR{$n}   = 'TCL';
	$URL{$n}     = 'https://www.tcl-lang.org/';
	$TESTS{$n}   = \&TEST_tcl;
	$DISABLE{$n} = \&DISABLE_tcl;
	$DEPS{$n}    = 'cc';
}
;1
