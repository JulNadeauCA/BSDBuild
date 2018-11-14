# Public domain
# vim:ts=4

sub Test_AgarAdaCore
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-ada-core-config', '--version',
                    'AGAR_ADA_CORE_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_ADA_CORE_VERSION');
		MkPrintSN('checking whether Agar-Core Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--cflags',
                        'AGAR_ADA_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--libs',
                        'AGAR_ADA_CORE_LIBS');
		MkCompileAda('HAVE_AGAR_ADA_CORE',
		             '${AGAR_ADA_CORE_CFLAGS}', '${AGAR_ADA_CORE_LIBS}', << "EOF");
with Agar;
with Agar.Init;
with Agar.Error;

procedure conftest is
begin
  if not Agar.Init.Init_Core then
    raise program_error with Agar.Error.Get_Error;
  end if;
end conftest;
EOF
		MkSaveIfTrue('${HAVE_AGAR_ADA_CORE}',
                     'AGAR_ADA_CORE_CFLAGS', 'AGAR_ADA_CORE_LIBS');
	MkElse;
		Disable_Agar_Ada_Core();
	MkEndif;
	return (0);
}

sub Disable_AgarAdaCore
{
	MkSaveUndef('HAVE_AGAR_ADA_CORE');
	MkSaveUndef('AGAR_ADA_CORE_CFLAGS', 'AGAR_ADA_CORE_LIBS');
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
	my $n = 'agar-ada-core';

	$DESCR{$n} = 'Ada bindings to Agar-Core';
	$URL{$n}   = 'http://libagar.org';
	$DEPS{$n}  = 'cc';

	$TESTS{$n}   = \&Test_AgarAdaCore;
	$DISABLE{$n} = \&Disable_AgarAdaCore;
	$EMUL{$n}    = \&Emul;
}
;1
