# vim:ts=4
#
# Copyright (c) 2018 Hypertriton, Inc. <http://hypertriton.com/>
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

my $testCode = << 'EOF';
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-ada-core-config', '--version', 'AGAR_ADA_CORE_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_ADA_CORE_VERSION');
		MkPrintSN('checking whether Agar-Core Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--cflags', 'AGAR_ADA_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--libs', 'AGAR_ADA_CORE_LIBS');
		MkCompileAda('HAVE_AGAR_ADA_CORE',
		           '${AGAR_ADA_CORE_CFLAGS}', '${AGAR_ADA_CORE_LIBS}', << "EOF");
with Agar;
with Agar.Init;
with Agar.Error;

procedure conftest is
  Options: Agar.Init.Init_Flags_t := (False, False, False);
begin
  if not Agar.Init.Init_Core ("conftest", Options) then
    raise program_error with Agar.Error.Get_Error;
  end if;
end conftest;
EOF
		MkSaveIfTrue('${HAVE_AGAR_ADA_CORE}', 'AGAR_ADA_CORE_CFLAGS', 'AGAR_ADA_CORE_LIBS');
	MkElse;
		MkSaveUndef('AGAR_ADA_CORE_CFLAGS', 'AGAR_ADA_CORE_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_ADA_CORE', 'ag_ada_core');
	} else {
		MkEmulUnavail('AGAR_ADA_CORE');
	}
	return (1);
}

BEGIN
{
	$DESCR{'agar-ada-core'} = 'Ada bindings to Agar-Core';
	$URL{'agar-ada-core'} = 'http://libagar.org';

	$TESTS{'agar-ada-core'} = \&Test;
	$DEPS{'agar-ada-core'} = 'cc';
	$EMUL{'agar-ada-core'} = \&Emul;
}

;1
