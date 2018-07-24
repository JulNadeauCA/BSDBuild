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
	
	MkExecOutputPfx($pfx, 'agar-core-ada-config', '--version', 'AGAR_CORE_ADA_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_CORE_ADA_VERSION');
		MkPrintSN('checking whether Agar-Core Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-core-ada-config', '--cflags', 'AGAR_CORE_ADA_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-ada-config', '--libs', 'AGAR_CORE_ADA_LIBS');
		MkCompileAda('HAVE_AGAR_CORE_ADA',
		           '${AGAR_CORE_ADA_CFLAGS}', '${AGAR_CORE_ADA_LIBS}', << "EOF");
with Agar.Core;
with Agar.Core.Init;
with Agar.Core.Error;

procedure conftest is
  package Init renames Agar.Core.Init;

  Options: Init.Init_Flags_t := (False, False, False);
begin
  if not Init.Init_Core ("conftest", Options) then
    raise program_error with Agar.Core.Error.Get_Error;
  end if;
end conftest;
EOF
		MkSaveIfTrue('${HAVE_AGAR_CORE_ADA}', 'AGAR_CORE_ADA_CFLAGS', 'AGAR_CORE_ADA_LIBS');
	MkElse;
		MkSaveUndef('AGAR_CORE_ADA_CFLAGS', 'AGAR_CORE_ADA_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_CORE_ADA', 'ag_core_ada');
	} else {
		MkEmulUnavail('AGAR_CORE_ADA');
	}
	return (1);
}

BEGIN
{
	$DESCR{'agar-core-ada'} = 'Agar-Core Ada bindings';
	$URL{'agar-core-ada'} = 'http://libagar.org';

	$TESTS{'agar-core-ada'} = \&Test;
	$DEPS{'agar-core-ada'} = 'cc';
	$EMUL{'agar-core-ada'} = \&Emul;
}

;1
