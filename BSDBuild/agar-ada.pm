# Public domain
# vim:ts=4

sub Test_AgarAda
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-ada-config', '--version', 'AGAR_ADA_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_ADA_VERSION');
		MkPrintSN('checking whether Agar Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-ada-config', '--cflags', 'AGAR_ADA_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-ada-config', '--libs', 'AGAR_ADA_LIBS');
		MkCompileAda('HAVE_AGAR_ADA',
		           '${AGAR_ADA_CFLAGS} ${AGAR_ADA_CORE_CFLAGS} ${AGAR_CFLAGS}',
				   '${AGAR_ADA_LIBS} ${AGAR_ADA_CORE_LIBS} ${AGAR_LIBS}', << "EOF");
with Agar.Init;
with Agar.Init_GUI;
with Agar.Error;

procedure conftest is
begin
  if not Agar.Init.Init_Core then
    raise program_error with Agar.Error.Get_Error;
  end if;
  if not Agar.Init_GUI.Init_GUI then
    raise program_error with Agar.Error.Get_Error;
  end if;
end conftest;
EOF
		MkSaveIfTrue('${HAVE_AGAR_ADA}', 'AGAR_ADA_CFLAGS', 'AGAR_ADA_LIBS');
	MkElse;
		Disable_AgarAda();
	MkEndif;
	return (0);
}

sub Disable_AgarAda
{
	MkSaveUndef('HAVE_AGAR_ADA',
	            'AGAR_ADA_CFLAGS',
	            'AGAR_ADA_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_ADA', 'ag_ada');
	} else {
		MkEmulUnavail('AGAR_ADA');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar-ada';

	$DESCR{$n} = 'Ada bindings to Agar-GUI';
	$URL{$n}   = 'http://libagar.org';
	$DEPS{$n}  = 'cc,agar,agar-ada-core';

	$TESTS{$n}   = \&Test_AgarAda;
	$DISABLE{$n} = \&Disable_AgarAda;
	$EMUL{$n}    = \&Emul;
}

;1
