# vim:ts=4
#
# Copyright (c) 2002-2018 Julien Nadeau Carriere <vedge@csoft.net>
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

our $OutputHeaderFile = undef;
our $OutputHeaderDir = 'config';
our $OutputLUA = 'configure.lua';
our $LUA = undef;
our $EmulOS = undef;
our $EmulOSRel = undef;
our $EmulEnv = undef;
our %MkDefinesToSave = ();
our $Cache = 0;
our %TESTS = ();
our %DISABLE = ();
our %DESCR = ();
our %URL = ();
our %EMUL = ();
our %EMULDEPS = ();
our %HELPENV = ();

#
# Bourne instructions.
#
sub MkBreak { print "break\n"; }
sub MkIf { print 'if [ ',shift,' ]; then',"\n"; }
sub MkIfExec { print 'if ',shift,'; then',"\n"; }
sub MkElif { print 'elif [ ',shift,' ]; then',"\n"; }
sub MkElse { print 'else',"\n"; }
sub MkEndif { print 'fi',"\n"; }
sub MkIfCmp
{
	my ($a, $test, $b) = @_;
	print 'if [ "', $a, '" '.$test.' "'.$b.'" ]; then', "\n";
}
sub MkIfEQ
{
	my ($a, $b) = @_;
	$b = '' unless defined($b);
	print 'if [ "', $a, '" = "'.$b.'" ]; then', "\n";
}
sub MkIfNE
{
	my ($a, $b) = @_;
	$a = '' unless defined($a);
	print 'if [ "', $a, '" != "'.$b.'" ]; then', "\n";
}
sub MkIfTrue { my $var = shift; MkIfEQ($var, 'yes'); }
sub MkIfFalse { my $var = shift; MkIfEQ($var, 'no'); }
sub MkIfTest
{
	my ($test, $a) = @_;
	print 'if [ '.$test.' "'.$a.'" ]; then', "\n";
}
sub MkIfExists { my $file = shift; MkIfTest('-e', $file); }
sub MkIfFile { my $file = shift; MkIfTest('-f', $file); }
sub MkIfDir { my $file = shift; MkIfTest('-d', $file); }
sub MkCaseIn { my $case = shift; print 'case "'.$case.'" in',"\n"; }
sub MkEsac { print "esac\n"; }
sub MkCaseBegin { my $case = shift; print $case.')',"\n"; }
sub MkCaseEnd { print ";;\n"; }
sub MkSetS { my ($arg, $val) = @_; print "$arg=\"$val\"\n"; }
sub MkPushIFS { my ($ifs) = shift; print 'bb_save_IFS=$IFS' . "\n"; print 'IFS=' . $ifs . "\n"; }
sub MkPopIFS { print 'IFS=$bb_save_IFS' . "\n"; }
sub MkFor { my ($i, $what) = @_; print 'for '.$i.' in '.$what.'; do' . "\n"; }
sub MkDone { print "done\n"; }
sub MkSetExec { my ($arg, $val) = @_; print "$arg=`$val`\n"; }
sub MkDefine { my ($arg, $val) = @_; print "$arg=\"$val\"\n"; }
sub MkAppend { my ($arg, $val) = @_; print "$arg=\"\${$arg} $val\"\n"; }
sub MkSet { my ($arg, $val) = @_; print "$arg=$val\n"; }
sub MkSetTrue { my ($arg) = @_; print "$arg=yes\n"; }
sub MkSetFalse { my ($arg) = @_; print "$arg=no\n"; }
sub MkAppend { my ($arg, $val) = @_; print "$arg=\"\${$arg} $val\"\n"; }

sub MkLog
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo "$msg" >>config.log
EOF
}

sub MkPrint
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo "$msg"
echo "$msg" >>config.log
EOF
}

sub MkPrintS
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo '$msg'
echo '$msg' >>config.log
EOF
}

sub MkPrintN
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
\$ECHO_N "$msg"
\$ECHO_N "$msg" >>config.log
EOF
}

sub MkPrintSN
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
\$ECHO_N '$msg'
\$ECHO_N '$msg' >>config.log
EOF
}

#
# Premake instructions
#
sub PmComment {
	my $com = shift;
	print "-- $com\n";
}
sub PmIf {
	my $cond = shift;
	print "if ($cond) then\n";
}
sub PmIfHDefined {
	my $def = shift;
	print "if (hdefs[\"$def\"] ~= nil) then\n";
}
sub PmEndif {
	my $cond = shift;
	print "end\n";
}
sub PmDefineBool {
	my $def = shift;
	print << "EOF";
table.insert(package.defines,{"$def"})
EOF
}
sub PmDefineString {
	my ($def, $val) = @_;
	print << "EOF";
table.insert(package.defines,{"$def=$val"})
EOF
}
sub PmIncludePath {
	my $path = shift;
	print << "EOF";
table.insert(package.includepaths,{"$path"})
EOF
}
sub PmLibPath {
	my $path = shift;
	print << "EOF";
table.insert(package.libpaths,{"$path"})
EOF
}
sub PmBuildFlag {
	my $flag = shift;
	print << "EOF";
table.insert(package.buildflags,{"$flag"})
EOF
}
sub PmLink {
	my $link = shift;
	print << "EOF";
table.insert(package.links,{"$link"})
EOF
}

# Emit a comment
sub MkComment
{
	foreach my $line (@_) {
		print '# ' . $line . "\n";
	}
}

sub MkCache
{
	my ($value, $key) = @_;

	if ($Cache) {
		MkIfNE('${cache}', '');
			print 'echo "' . $value . '" >${cache}/'.$key."\n";
		MkEndif;
	}
}

# Write the standard output of a program into variable "$define".
# Set an empty string and $MK_EXEC_FOUND='No' if the binary is not found.
sub MkExecOutput
{
	my ($bin, $args, $define) = @_;

	if ($Cache) {
		MkSet('MK_EXEC_FOUND', 'No');
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/exec-'.$define);
				MkSetExec('MK_EXEC_FOUND', 'cat ${cache}/exec-found-'.$define);
				MkSet    ('MK_CACHED',     'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}

	MkSet($define, '');
	MkPushIFS('$PATH_SEPARATOR');
	MkFor('path', '$PATH');
		MkIfExists('${path}/'.$bin);
			MkSetExec($define, '${path}/'.$bin.' '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkBreak;
		MkElif('-e ${path}/'.$bin.'.exe');
			MkSetExec($define, '${path}/'.$bin.'.exe '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkBreak;
		MkEndif;
	MkDone;
	MkPopIFS();

	if ($Cache) {
			MkCache('$'.$define,      'exec-'.$define);
			MkCache('$MK_EXEC_FOUND', 'exec-found-'.$define);

		MkEndif;	# !MK_CACHED
	}
}

# Variant of MkExecOutput() accepting a prefix argument.
# If prefix is empty, fallback to autodetection.
sub MkExecOutputPfx
{
	my ($pfx, $bin, $args, $define) = @_;

	MkSet($define, '');
	MkPushIFS('$PATH_SEPARATOR');
	MkFor('path', '$PATH');
		MkIfExists('${path}/'.$bin);
			MkSetExec($define, '${path}/'.$bin.' '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkSetS('MK_EXEC_PATH', '${path}/'.$bin);
			MkBreak;
		MkElif('-e "${path}/'.$bin.'.exe"');
			MkSetExec($define, '${path}/' . $bin.'.exe '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkSetS('MK_EXEC_PATH', '${path}/'.$bin.'.exe');
			MkBreak;
		MkEndif;
	MkDone;
	MkPopIFS;
}

sub MkIfPkgConfig
{
	my ($pkg) = @_;

	print << "EOF";
if [ "\${PKGCONFIG}" != '' -a "`\${PKGCONFIG} --variable=prefix $pkg 2>/dev/null`" != '' ]; then
EOF
}

# Variant of MkExecOutputPfx() for pkg-config.
sub MkExecPkgConfig
{
	my ($pfx, $pkg, $args, $define) = @_;

	MkIfNE('$pfx', '');
		MkSetExec('MK_EXEC_PKGPREFIX', '$PKGCONFIG --variable=prefix '.$pkg.
		                               ' 2>/dev/null');
		MkIfNE('$MK_EXEC_PKGPREFIX', '$pfx');
			MkPrint('* ');
			MkPrint("* ERROR: According to pkg-config, $pkg is installed in prefix: ");
			MkPrint("* \$MK_EXEC_PKGPREFIX, but the prefix $pfx was given.");
			MkPrint('* ');
			MkPrint("* Please indicate correct $pkg prefix (or omit for autodetect).");
			MkPrint('* ');
			MkFail('Package prefix mismatch');
		MkEndif;
	MkEndif;

	MkSetExec($define, '$PKGCONFIG '.$pkg.' '.$args.' 2>/dev/null');
}

# 
# Variant of MkExecOutput() which tests and warns if the binary appears more
# than once in $PATH (ignoring copies with alternate executable suffixes).
# If the binary exists only once under $PATH, set $MK_EXEC_UNIQUE to Yes.
# 
sub MkExecOutputUnique
{
	my ($bin, $args, $define) = @_;

	MkSet('MK_EXEC_FOUND', 'No');
	MkSet('MK_EXEC_UNIQUE', 'No');
	MkSet('MK_EXEC_FOUND_PATH', 'No');
	MkSet($define, '');

	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/exec-'.$define);
				MkSetExec($define,              'cat ${cache}/exec-'.$define);
				MkSetExec('MK_EXEC_FOUND',      'cat ${cache}/exec-found-'.$define);
				MkSetExec('MK_EXEC_FOUND_PATH', 'cat ${cache}/exec-found-path-'.$define);
				MkSet    ('MK_CACHED',          'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}

	MkSet($define, '');
	MkPushIFS('$PATH_SEPARATOR');
	MkFor('path', '$PATH');
		MkIfExists('${path}/'.$bin);
			MkIfEQ('${MK_EXEC_FOUND}', 'Yes');
				MkPrint('yes.');
				MkIfNE('${MK_EXEC_FOUND_PATH}', '${path}/'.$bin.'.exe');
					MkPrint('* WARNING: Multiple '.$bin.' in PATH '.
					        '(using ${MK_EXEC_FOUND_PATH})');
				MkEndif;
				MkBreak;
			MkEndif;
			MkSetExec($define, '${path}/'.$bin.' '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkSet('MK_EXEC_FOUND_PATH', '${path}/'.$bin);
		MkElif('-e ${path}/'.$bin.'.exe');
			MkIfEQ('${MK_EXEC_FOUND}', 'Yes');
				MkPrint('yes.');
				MkIfNE('${MK_EXEC_FOUND_PATH}', '${path}/'.$bin);
					MkPrint('* WARNING: Multiple '.$bin.' in PATH '.
					        '(using ${MK_EXEC_FOUND_PATH})');
				MkEndif;
				MkBreak;
			MkEndif;
			MkSetExec($define, '${path}/'.$bin.'.exe '.$args);
			MkSet('MK_EXEC_FOUND', 'Yes');
			MkSet('MK_EXEC_FOUND_PATH', '${path}/'.$bin.'.exe');
		MkEndif;
	MkDone;			# path in $PATH
	MkPopIFS();

	if ($Cache) {
			MkCache('$'.$define,           'exec-'.$define);
			MkCache('$MK_EXEC_FOUND',      'exec-found-'.$define);
			MkCache('$MK_EXEC_FOUND_PATH', 'exec-found-path-'.$define);
		MkEndif;	# !MK_CACHED
	}
}

sub MkIfFound
{
	my ($pfx, $ver, $verDefn) = @_;

	MkIfNE('${'.$verDefn.'}', '');
		MkIfNE($pfx, '');
			MkPrint("yes (\$$verDefn in $pfx)");
		MkElse;
			MkPrint("yes (\$$verDefn)");
		MkEndif;
	if ($ver ne '') {
		MkTestVersion($verDefn, $ver);
		MkIfEQ('${MK_VERSION_OK}', 'no');
			MkPrintS('*');
			MkPrint ("* Minimum required version is $ver (found \$$verDefn)");
			MkPrintS('*');
		MkEndif;
	} else {
		MkDefine('MK_VERSION_OK', 'yes');
	}
	MkElse;
		MkIfNE($pfx, '');
			MkPrint("no (not in $pfx)");
		MkElse;
			MkPrintS('no');
		MkEndif;
		MkDefine('MK_VERSION_OK', 'no');
	MkEndif;
	MkIfEQ('${MK_VERSION_OK}', 'yes');
}

sub Log
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;							# Escape quotes
	$msg =~ tr/()/ /;
	return "echo \"$msg\" >>config.log\n";
}

sub MkFail
{
	my $msg = shift;
    
	$msg =~ s/["]/\"/g;							# Escape quotes
	$msg =~ tr/()/ /;
	print << "EOF";
echo \"$msg\"
exit 1
EOF
}

sub MKSave
{
    my $var = shift;
    my $s = '';
   
	$s = "echo \"$var=\$$var\" >>Makefile.config\n";
    return ($s);
}

sub MkSaveMK
{
	foreach my $var (@_) {
		$MkDefinesToSave{$var} = 1;
	}
}

sub MkSaveMK_Commit
{
	foreach my $var (sort keys %MkDefinesToSave) {
		print << "EOF";
echo "$var=\$$var" >>Makefile.config
EOF
		if ($OutputLUA) {
			print << "EOF";
echo "mdefs[\\"$var\\"] = \\"\$$var\\"" >>$OutputLUA
EOF
		}
	}
}

sub MkSaveUndef
{
	foreach my $var (@_) {
		if ($OutputHeaderFile) {
			print "echo '#undef $var' >>\$iconf\n";
		}
		if ($OutputHeaderDir) {
			my $include = '$bb_incdir/'.lc($var).'.h';
			print "echo '#undef $var' >$include\n";
		}
		if ($OutputLUA) {
			print << "EOF";
echo 'hdefs["$var"] = nil' >>$OutputLUA
EOF
		}
	}
}

sub MkSaveDefine
{
	foreach my $var (@_) {
		if ($OutputHeaderFile) {
			print << "EOF";
echo '#ifndef $var' >>\$iconf
echo "#define $var \\"\$$var\\"" >>\$iconf
echo '#endif' >>\$iconf
EOF
		}
		if ($OutputHeaderDir) {
			my $include = '$bb_incdir/'.lc($var).'.h';
			print << "EOF";
bb_o=$include
echo '#ifndef $var' >\$bb_o
echo "#define $var \\"\$$var\\"" >>\$bb_o
echo '#endif' >>\$bb_o
EOF
		}
		if ($OutputLUA) {
			print << "EOF";
echo "hdefs[\\"$var\\"] = \\"\$$var\\"" >>$OutputLUA
EOF
		}
	}
}

sub MkSaveDefineUnquoted
{
	foreach my $var (@_) {
		if ($OutputHeaderFile) {
			print << "EOF";
echo '#ifndef $var' >>\$iconf
echo "#define $var \$$var" >>\$iconf
echo '#endif' >>\$iconf
EOF
		}
		if ($OutputHeaderDir) {
			my $include = $OutputHeaderDir.'/'.lc($var).'.h';
			print << "EOF";
bb_o=$include
echo '#ifndef $var' >\$bb_o
echo "#define $var \$$var" >>\$bb_o
echo '#endif' >>\$bb_o
EOF
		}
		if ($OutputLUA) {
			print << "EOF";
echo "hdefs[\\"$var\\"] = \$$var" >>$OutputLUA
EOF
		}
	}
}

sub MkSave
{
	foreach my $var (@_) {
		MkSaveMK($var);
		MkSaveDefine($var);
	}
}

sub MkSaveIfTrue
{
	my $cond = shift(@_);

	MkIfTrue($cond);
		foreach my $var (@_) {
			MkSaveMK($var);
			MkSaveDefine($var);
		}
	MkElse;
		foreach my $var (@_) {
			MkSaveUndef($var);
			MkDefine($var, '');
		}
	MkEndif;
}

sub MkCleanup
{
	MkIfNE('${keep_conftest}', 'yes');
		print 'rm -f '.join(' ',@_)."\n";
	MkEndif;
}

sub TryCompile
{
	my ($define, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');

	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/ctest-'.$define);
				MkSetExec($define,             'cat ${cache}/ctest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/ctest-status-'.$define);
				MkSet    ('MK_CACHED',         'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}

	print 'cat << EOT >conftest$$.c', "\n";
	print $code, "EOT\n";
	print '$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest$$ conftest$$.c ' .
	      "2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	if ($Cache) {
		MkEndif;	# !MK_CACHED
	}

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSet($define, 'yes');
		MkSaveDefine($define);
	MkElse;
		MkPrintS('no');
		MkSet($define, 'no');
		MkSaveUndef($define);
	MkEndif;

	MkCache('$'.$define,          'ctest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'ctest-status-'.$define);

	MkCleanup('conftest$$.c', '$testdir/conftest$$$EXECSUFFIX');
}

sub BeginTestHeaders
{
	MkSetS('TEST_CFLAGS_ORIG', '${TEST_CFLAGS}');
	MkSet('TEST_HEADERS', 'Yes');
}

sub EndTestHeaders
{
	MkSetS('TEST_CFLAGS', '${TEST_CFLAGS_ORIG}');
	MkSet('TEST_HEADERS', '');
}

sub MkTestVersion
{
	my ($verDef, $ver) = @_;

	if (!defined($ver) || !$ver) {
		return;
	}
	my @verSpec = split(/\./, $ver);
	if (@verSpec >= 3) {
		#
		# Test for x.y.z
		#
		print << "EOF";
MK_VERSION_MAJOR=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\1/'`;
MK_VERSION_MINOR=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\2/'`;
MK_VERSION_MICRO=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\3/'`;
MK_VERSION_OK=no
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
MK_VERSION_OK=yes
elif [ \$MK_VERSION_MAJOR -eq $verSpec[0] ]; then
if [ "\$MK_VERSION_MINOR" = '' ]; then
MK_VERSION_OK=yes
else
if [ \$MK_VERSION_MINOR -gt $verSpec[1] ]; then
MK_VERSION_OK=yes
elif [ \$MK_VERSION_MINOR -eq $verSpec[1] ]; then
if [ "\$MK_VERSION_MICRO" = '' ]; then
MK_VERSION_OK=yes
else
if [ \$MK_VERSION_MICRO -ge $verSpec[2] ]; then
MK_VERSION_OK=yes
fi
fi
fi
fi
fi
EOF
	} elsif (@verSpec >= 2) {
		#
		# Test for x.y
		#
		print << "EOF";
MK_VERSION_MAJOR=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\1/'`;
MK_VERSION_MINOR=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\2/'`;
MK_VERSION_OK=no
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
MK_VERSION_OK=yes
elif [ \$MK_VERSION_MAJOR -eq $verSpec[0] ]; then
if [ "\$MK_VERSION_MINOR" = '' ]; then
MK_VERSION_OK=yes
else
if [ \$MK_VERSION_MINOR -ge $verSpec[1] ]; then
MK_VERSION_OK=yes
fi
fi
fi
EOF
	} elsif (@verSpec >= 1) {
		#
		# Test for x
		#
		print << "EOF";
MK_VERSION_MAJOR=`echo "\$$verDef" |sed 's/\\([0-9]*\\).\\([0-9]*\\).\\([0-9]*\\).*/\\1/'`;
MK_VERSION_OK=no
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
MK_VERSION_OK=yes
elif [ \$MK_VERSION_MAJOR -ge $verSpec[0] ]; then
MK_VERSION_OK=yes
fi
EOF
	}
}

sub DetectHeaderC
{
	my $def = shift;

	print 'echo >conftest$$.c',"\n";
	while (my $hdr = shift) {
		print "echo '#include $hdr' >>conftest\$\$.c\n";
	}
	print << 'EOF';
echo 'int main (int argc, char *argv[]) { return (0); }' >>conftest$$.c
EOF
	MkSet('MK_COMPILE_STATUS', 'OK');
	print << 'EOF';
$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest$$ conftest$$.c 2>>config.log
EOF
	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	print "rm -f conftest$$.c $testdir/conftest$$$EXECSUFFIX\n";

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkSet($def, 'yes');
		MkSaveDefine($def);
		MkIfEQ('${TEST_HEADERS}', 'Yes');
			MkSetS('TEST_CFLAGS', "\${TEST_CFLAGS} -D$def");
		MkEndif;
	MkElse;
		MkSet($def, 'no');
		MkSaveUndef($def);
	MkEndif;
}

sub MkSaveCompileSuccess ($)
{
	my $define = shift;
		
	MkSet($define, 'yes');
	MkSaveMK($define);
	MkSaveDefine($define);
}

sub MkSaveCompileFailed ($)
{
	my $define = shift;
		
	MkSet($define, 'no');
	MkSaveMK($define);
	MkSaveUndef($define);
}

#
# Compile and run a test C program. If the program returns a non-zero
# exit code, the test fails.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkCompileAndRunC
{
	my ($define, $cflags, $libs, $code) = @_;

	MkSet('MK_COMPILE_STATUS', 'OK');
	MkSet('MK_RUN_STATUS', 'OK');

	print 'cat << EOT >conftest$$.c', "\n";
	print $code, "EOT\n";
	print '$CC $CFLAGS $TEST_CFLAGS ' . $cflags .
	      ' -o $testdir/conftest$$ conftest$$.c ' . $libs .
	      " 2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		print '(cd $testdir && ./conftest$$$EXECSUFFIX) >>config.log', "\n";
		MkIfEQ('$?', '0');
			MkPrintS('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrintS('no, test program failed');
			MkSetS('MK_RUN_STATUS', 'FAIL $?');
			MkSaveCompileFailed($define);
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkSetS('MK_RUN_STATUS', 'FAIL $?');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCleanup('conftest$$.c', '$testdir/conftest$$$EXECSUFFIX');
}

#
# Compile and run a test C++ program. If the program returns a non-zero
# exit code, the test fails.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkCompileAndRunCXX
{
	my ($define, $cxxflags, $libs, $code) = @_;

	MkSet('MK_COMPILE_STATUS', 'OK');

	print 'cat << EOT >conftest$$.cpp', "\n";
	print $code, "EOT\n";
	print '$CXX $CXXFLAGS $TEST_CXXFLAGS ' . $cxxflags .
	      ' -o $testdir/conftest$$ conftest$$.cpp ' . $libs .
	      " 2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		print '(cd $testdir && ./conftest$$$EXECSUFFIX) >>config.log', "\n";
		MkIfEQ('$?', '0');
			MkPrintS('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrintS('no, test program failed');
			MkSaveCompileFailed($define);
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCleanup('conftest$$.cpp', '$testdir/conftest$$$EXECSUFFIX');
}

sub TryCompileFlagsAda
{
	my ($define, $flags, $code) = @_;

	MkSet('MK_COMPILE_STATUS', 'OK');

	print 'cat << EOT >conftest.adb', "\n";
	print $code, "EOT\n";
	print '$ADA $ADAFLAGS $TEST_ADAFLAGS ' . $flags . ' -c conftest.adb ' .
	      "2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('compiler failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkElse;
		print '$ADABIND $ADABFLAGS conftest 2>>config.log', "\n";
		MkIfNE('$?', '0');
			MkLog('binder failed $?');
			MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
		MkEndif;
	MkEndif;

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;
	
	MkCleanup('conftest.adb', 'conftest.ali', 'conftest.o', 'conftest$EXECSUFFIX',
	          '"b~conftest.adb"', '"b~conftest.ads"');
}

sub TryCompileFlagsC
{
	my ($define, $flags, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');

	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/ctest-'.$define);
				MkSetExec($define,             'cat ${cache}/ctest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/ctest-status-'.$define);
				MkSet    ('MK_CACHED',         'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}

	print 'cat << EOT >conftest$$.c', "\n";
	print $code, "EOT\n";
	print '$CC $CFLAGS $TEST_CFLAGS ' . $flags .
	      ' -o $testdir/conftest$$ conftest$$.c ' .
	      "2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;
	
	if ($Cache) {
		MkEndif;	# !MK_CACHED
	}

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes') unless $Quiet;
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no') unless $Quiet;
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'ctest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'ctest-status-'.$define);

	MkCleanup('conftest$$.c', '$testdir/conftest$$$EXECSUFFIX');
}

sub TryCompileFlagsCXX
{
	my ($define, $flags, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');

	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/cxxtest-'.$define);
				MkSetExec($define,             'cat ${cache}/cxxtest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/cxxtest-status-'.$define);
				MkSet('MK_CACHED', 'Yes');
			MkEndif;
		MkEndif;
		MkIfNE('${MK_CACHED}', 'No');
	}

	print 'cat << EOT >conftest$$.cpp', "\n";
	print $code, "EOT\n";
	print '$CXX $CXXFLAGS $TEST_CXXFLAGS ' . $flags .
	      ' -o $testdir/conftest$$ conftest$$.cpp -lstdc++ ' .
	      "2>>config.log\n";

	MkIfNE('$?', '0');
		MkPrint('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	if ($Cache) {
		MkEndif;
	}
	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'cxxtest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'cxxtest-status-'.$define);

	MkCleanup('conftest$$.cpp', '$testdir/conftest$$$EXECSUFFIX');
}

#
# Compile a test Ada program. If compilation fails, the test fails. The
# test program is never executed. Returns yes or no in $define.
#
sub MkCompileAda
{
	my ($define, $cflags, $libs, $code) = @_;

	print << "EOF";
ada_cflags=""
for F in $cflags; do
    case "\$F" in
    -I*)
        ada_cflags="\$ada_cflags \$F";
        ;;
    esac;
done
EOF
	MkSet('MK_COMPILE_STATUS', 'OK');

	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/adatest-'.$define);
				MkSetExec($define,             'cat ${cache}/adatest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/adatest-status-'.$define);
				MkSet('MK_CACHED',             'Yes');
			MkEndif;
		MkEndif;
		MkIfNE('${MK_CACHED}', 'No');
	}

	print 'cat << EOT >conftest.adb', "\n";
	print $code, "EOT\n";
	print '$ADA $ADAFLAGS $TEST_ADAFLAGS $ada_cflags -c conftest.adb ' .
	      "2>>config.log\n";

	MkIfNE('$?', '0');
		MkPrint('compiler failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkElse;
		print '$ADABIND $ADABFLAGS $ada_cflags conftest ' .
		      "2>>config.log\n";
		MkIfNE('$?', '0');
			MkPrint('binder failed $?');
			MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
		MkElse;
		    print '$ADALINK $ADALFLAGS $ada_cflags conftest ' . $libs .
			      " 2>>config.log\n";
			MkIfNE('$?', '0');
				MkPrint('linker failed $?');
				MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
			MkEndif;
		MkEndif;
	MkEndif;
	
	if ($Cache) {
		MkEndif;
	}

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'adatest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'adatest-status-'.$define);

	MkCleanup('conftest.adb', 'conftest.ali', 'conftest.o',
	          'conftest$EXECSUFFIX', '"b~conftest.adb"', '"b~conftest.ads"');
}

#
# Compile a test C program. If compilation fails, the test fails. The
# test program is never executed. Returns yes or no in $define.
#
sub MkCompileC
{
	my ($define, $cflags, $libs, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');
	
	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/ctest-'.$define);
				MkSetExec($define,             'cat ${cache}/ctest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/ctest-status-'.$define);
				MkSet    ('MK_CACHED',         'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}

	print 'cat << EOT >conftest$$.c', "\n";
	print $code, "EOT\n";
	print '$CC $CFLAGS $TEST_CFLAGS ' . $cflags .
	      ' -o $testdir/conftest$$ conftest$$.c '. $libs .
	      " 2>>config.log\n";

	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;
	
	if ($Cache) {
		MkEndif;	# !MK_CACHED
	}

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes') unless $Quiet;
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no') unless $Quiet;
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'ctest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'ctest-status-'.$define);

	MkCleanup('conftest$$.c', '$testdir/conftest$$$EXECSUFFIX');
}

#
# Compile a test Objective-C program. If compilation fails, the test fails.
# The test program is never executed. Returns yes or no in $define.
#
sub MkCompileOBJC
{
	my ($define, $cflags, $libs, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');
	
	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/objctest-'.$define);
				MkSetExec($define,             'cat ${cache}/objctest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/objctest-status-'.$define);
				MkSet    ('MK_CACHED',         'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}
	
	print 'cat << EOT >conftest$$.m', "\n";
	print $code, "EOT\n";
	print '$CC $CFLAGS $TEST_CFLAGS ' . $cflags .
	      ' -x objective-c -o $testdir/conftest$$ conftest$$.m ' . $libs .
	      " 2>>config.log\n";
	
	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'objctest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'objctest-status-'.$define);

	MkCleanup('conftest$$.m', '$testdir/conftest$$$EXECSUFFIX');
}

#
# Compile a test C++ program. If compilation fails, the test fails. The
# test program is never executed. Returns yes or no in $define.
#
sub MkCompileCXX
{
	my ($define, $cxxflags, $libs, $code) = @_;
	
	MkSet('MK_COMPILE_STATUS', 'OK');
	
	if ($Cache) {
		MkSet('MK_CACHED', 'No');
		MkIfNE('${cache}', '');
			MkIfExists('${cache}/cxxtest-'.$define);
				MkSetExec($define,             'cat ${cache}/cxxtest-'.$define);
				MkSetExec('MK_COMPILE_STATUS', 'cat ${cache}/cxxtest-status-'.$define);
				MkSet    ('MK_CACHED',         'Yes');
			MkEndif;
		MkEndif;
		MkIfEQ('${MK_CACHED}', 'No');
	}
	
	print 'cat << EOT >conftest$$.cpp', "\n";
	print $code, "EOT\n";
	print '$CXX $CXXFLAGS $TEST_CXXFLAGS ' . $cxxflags .
	      ' -o $testdir/conftest$$ conftest$$.cpp ' . $libs .
	      " 2>>config.log\n";
	
	MkIfNE('$?', '0');
		MkLog('failed $?');
		MkSetS('MK_COMPILE_STATUS', 'FAIL $?');
	MkEndif;

	if ($Cache) {
		MkEndif;	# !MK_CACHED
	}

	MkIfEQ('${MK_COMPILE_STATUS}', 'OK');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCache('$'.$define,          'cxxtest-'.$define);
	MkCache('$MK_COMPILE_STATUS', 'cxxtest-status-'.$define);

	MkCleanup('conftest$$.cpp', '$testdir/conftest$$$EXECSUFFIX');
}

# Run a test Perl script. Returns yes or no in $define.
sub MkRunPerl
{
	my $define = shift;
	my $args = shift;
	my $code = shift;

	$code =~ s/\$/\\\$/g;

	print << "EOF";
cat << EOT >\$testdir/conftest\$\$.pl
$code
EOT
(cd \$testdir && perl conftest\$\$.pl) >>config.log
EOF
	MkIfEQ('$?', '0');
		MkPrintS('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrintS('no (script failed)');
		MkSaveCompileFailed($define);
	MkEndif;

	MkCleanup('$testdir/conftest$$.pl');
}

# Specify module availability under Windows platforms in Emul()
sub MkEmulWindows
{
	my $module = shift;
	my $libs = shift;

	MkDefine("HAVE_${module}", "yes");
	MkSaveDefine("HAVE_${module}");

	MkDefine("${module}_CFLAGS", "");
	MkDefine("${module}_LIBS", "$libs");
	MkSave("${module}_CFLAGS", "${module}_LIBS");
}

# Specify module availability under Windows platforms in Emul()
# No CFLAGS/LIBS are defined.
sub MkEmulWindowsSYS
{
	my $module = shift;

	if ($module =~ /^_/) {
		MkDefine($module, "yes");
		MkSaveDefine($module);
	} else {
		MkDefine("HAVE_${module}", "yes");
		MkSaveDefine("HAVE_${module}");
	}
}

# Specify module unavailability in Emul().
sub MkEmulUnavail
{
	foreach my $module (@_) {
		MkDefine("HAVE_${module}", "no");
		MkSaveUndef("HAVE_${module}");

		MkDefine("${module}_CFLAGS", "");
		MkDefine("${module}_LIBS", "");
		MkSave("${module}_CFLAGS", "${module}_LIBS");
	}
}

# Specify module unavailability in Emul(), without CFLAGS/LIBS.
sub MkEmulUnavailSYS
{
	foreach my $module (@_) {
		if ($module =~ /^_/) {
			MkDefine($module, "no");
			MkSaveUndef($module);
		} else {
			MkDefine("HAVE_${module}", "no");
			MkSaveUndef("HAVE_${module}");
		}
	}
}

sub RegisterEnvVar
{
	my ($var, $desc) = @_;

	if ($var =~ /\"(.*)\"/) { $var = $1; }
	if ($desc =~ /\"(.*)\"/) { $desc = $1; }
	my $dvar = pack('A' x 12, split('', $var));
	$HELPENV{$var} = "echo '    $dvar $desc'";
}

BEGIN
{
    require Exporter;
    $| = 1;
    $^W = 0;

    @ISA = qw(Exporter);
    @EXPORT = qw($Quiet $Cache $OutputLUA $OutputHeaderFile $OutputHeaderDir $LUA $EmulOS $EmulOSRel $EmulEnv %TESTS %DISABLE %DESCR %URL %HELPENV MkComment MkCache MkExecOutput MkExecOutputPfx MkExecPkgConfig MkExecOutputUnique MkFail MKSave MkCleanup TryCompile MkCompileAda MkCompileC MkCompileOBJC MkCompileCXX MkCompileAndRunC MkCompileAndRunCXX TryCompileFlagsAda TryCompileFlagsC TryCompileFlagsCXX Log MkDefine MkSet MkSetS MkSetExec MkSetTrue MkSetFalse MkPushIFS MkPopIFS MkFor MkDone MkAppend MkBreak MkIfExec MkIf MkIfCmp MkIfEQ MkIfNE MkIfTrue MkIfFalse MkIfTest MkIfExists MkIfFile MkIfDir MkCaseIn MkEsac MkCaseBegin MkCaseEnd MkElif MkElse MkEndif MkSaveMK MkSaveMK_Commit MkSaveDefine MkSaveDefineUnquoted MkSaveUndef MkSave MkSaveIfTrue MkLog MkPrint MkPrintN MkPrintS MkPrintSN MkIfFound PmComment PmIf PmEndif PmIfHDefined PmDefineBool PmDefineString PmIncludePath PmLibPath PmBuildFlag PmLink DetectHeaderC BeginTestHeaders EndTestHeaders MkTestVersion MkEmulWindows MkEmulWindowsSYS MkEmulUnavail MkEmulUnavailSYS RegisterEnvVar);
}
;1
