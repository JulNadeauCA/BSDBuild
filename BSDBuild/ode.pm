# vim:ts=4
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sub Test
{
	my ($ver) = @_;
	
	MkExecOutput('ode-config', '--version', 'ODE_VERSION');
	MkExecOutput('ode-config', '--cflags', 'ODE_CFLAGS');
	MkExecOutput('ode-config', '--libs', 'ODE_LIBS');
	
	MkIf('"${ODE_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether ODE works...');
		MkCompileC('HAVE_ODE', '${ODE_CFLAGS}', '${ODE_LIBS}', << 'EOF');
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
		MkIf('"${HAVE_ODE}" != "no"');
			MkSaveMK('ODE_CFLAGS', 'ODE_LIBS');
			MkSaveDefine('ODE_CFLAGS', 'ODE_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_ODE');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'ode'} = \&Test;
	$DESCR{'ode'} = 'ODE (http://www.ode.org/)';
}

;1