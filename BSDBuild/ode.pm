# Public domain

my $testCode = << 'EOF';
#include <ode/ode.h>

int main(int argc, char *argv[]) {
	dWorldID world;
	dJointGroupID jgroup;
	world = dWorldCreate();
	jgroup = dJointGroupCreate(10000);
	dWorldSetGravity(world, 0, 0, -0.5);
	dJointGroupDestroy(jgroup);
	dWorldDestroy(world);
	return (0);
}
EOF

sub TEST_ode
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'ode-config', '--version', 'ODE_VERSION');
	MkExecOutputPfx($pfx, 'ode-config', '--cflags', 'ODE_CFLAGS');
	MkExecOutputPfx($pfx, 'ode-config', '--libs', 'ODE_LIBS');
	MkDefine('ODE_LIBS', '${ODE_LIBS} -lstdc++ -lm');
	MkIfFound($pfx, $ver, 'ODE_VERSION');
		MkPrintSN('checking whether ODE works...');
		MkCompileC('HAVE_ODE',
		           '${ODE_CFLAGS}', '${ODE_LIBS}', $testCode);
		MkIfFalse('${HAVE_ODE}');
			MkDisableFailed('ode');
		MkEndif;
	MkElse;
		MkDisableNotFound('ode');
	MkEndif;
}

sub DISABLE_ode
{
	MkDefine('HAVE_ODE', 'no') unless $TestFailed;
	MkDefine('ODE_CFLAGS', '');
	MkDefine('ODE_LIBS', '');
	MkSaveUndef('HAVE_ODE');
}

BEGIN
{
	my $n = 'ode';

	$DESCR{$n}   = 'Open Dynamics Engine';
	$URL{$n}     = 'http://www.ode.org';
	$TESTS{$n}   = \&TEST_ode;
	$DISABLE{$n} = \&DISABLE_ode;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'ODE_CFLAGS ODE_LIBS';
}
;1
