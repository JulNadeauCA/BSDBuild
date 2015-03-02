# vim:ts=4
#
# Copyright (c) 2002-2012 Hypertriton, Inc. <http://hypertriton.com/>
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


#
# Bourne instructions.
#
sub MkBreak { print "break\n"; }
sub MkIf { print 'if [ ',shift,' ]; then',"\n"; }
sub MkElif { print 'elif [ ',shift,' ]; then',"\n"; }
sub MkElse { print 'else',"\n"; }
sub MkEndif { print 'fi;',"\n"; }
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
sub MkIfExists { my $file = shift; MkIfTest('-e ', $file); }
sub MkIfFile { my $file = shift; MkIfTest('-f ', $file); }
sub MkIfDir { my $file = shift; MkIfTest('-d ', $file); }
sub MkCaseIn { my $case = shift; print 'case "'.$case.'" in',"\n"; }
sub MkEsac { print "esac\n"; }
sub MkCaseBegin { my $case = shift; print $case.')',"\n"; }
sub MkCaseEnd { print ";;\n"; }

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

# Write the standard output of a program into variable "$define".
# Set an empty string and $MK_EXEC_FOUND="No" if the binary is not found.
sub MkExecOutput
{
	my ($bin, $args, $define) = @_;

	if ($Cache) {
		print << "EOF";
MK_EXEC_FOUND="No"
MK_CACHED="No"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/exec-$define" ]; then
		$define=`cat \${cache}/exec-$define`
		MK_EXEC_FOUND=`cat \${cache}/exec-found-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	$define=""
	for path in `echo \$PATH | sed 's/:/ /g'`; do
		if [ -e "\${path}/$bin" ]; then
			$define=`\${path}/$bin $args`
			MK_EXEC_FOUND="Yes"
			break
		fi
	done
	if [ "\${cache}" != "" ]; then
		echo "\$$define" > \${cache}/exec-$define
		echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
	fi
fi
EOF
	} else {
		print << "EOF";
MK_EXEC_FOUND="No"
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -e "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
		MK_EXEC_FOUND="Yes"
		break
	fi
done
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/exec-$define
	echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
fi
EOF
	}
}

# Variant of MkExecOutput() accepting a prefix argument.
# If prefix is empty, fallback to autodetection.
sub MkExecOutputPfx
{
	my ($pfx, $bin, $args, $define) = @_;

	if ($Cache) {
		print << "EOF";
MK_EXEC_FOUND="No"

if [ "$pfx" != "" ]; then
	if [ -e "$pfx/bin/$bin" ]; then
		$define=`$pfx/bin/$bin $args`
		MK_EXEC_FOUND="Yes"
	fi
else
	MK_CACHED="No"
	if [ "\${cache}" != "" ]; then
		if [ -e "\${cache}/exec-$define" ]; then
			$define=`cat \${cache}/exec-$define`
			MK_EXEC_FOUND=`cat \${cache}/exec-found-$define`
			MK_CACHED="Yes"
		fi
	fi
	if [ "\${MK_CACHED}" = "No" ]; then
		$define=""
		for path in `echo \$PATH | sed 's/:/ /g'`; do
			if [ -e "\${path}/$bin" ]; then
				$define=`\${path}/$bin $args`
				MK_EXEC_FOUND="Yes"
				break
			fi
		done
		if [ "\${cache}" != "" ]; then
			echo "\$$define" > \${cache}/exec-$define
			echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
		fi
	fi
fi
EOF
	} else {
		print << "EOF";
MK_EXEC_FOUND="No"

if [ "$pfx" != "" ]; then
	if [ -e "$pfx/bin/$bin" ]; then
		$define=`$pfx/bin/$bin $args`
		MK_EXEC_FOUND="Yes"
	fi
else
	$define=""
	for path in `echo \$PATH | sed 's/:/ /g'`; do
		if [ -e "\${path}/$bin" ]; then
			$define=`\${path}/$bin $args`
			MK_EXEC_FOUND="Yes"
			break
		fi
	done
fi
EOF
	}
}

sub MkIfPkgConfig
{
	my ($pkg) = @_;

	print << "EOF";
if [ "\${PKGCONFIG}" != "" -a "`\${PKGCONFIG} --variable=prefix $pkg 2>/dev/null`" != "" ]; then
EOF
}

# Variant of MkExecOutputPfx() for pkg-config.
sub MkExecPkgConfig
{
	my ($pfx, $pkg, $args, $define) = @_;

	print << "EOF";
if [ "$pfx" != "" ]; then
	MK_EXEC_PKGPREFIX=`\$PKGCONFIG --variable=prefix $pkg 2>/dev/null`
	if [ "\$MK_EXEC_PKGPREFIX" != "$pfx" ]; then
		echo " "
		echo "* "
		echo "* ERROR: According to pkg-config, $pkg is installed in prefix: "
		echo "* \$MK_EXEC_PKGPREFIX, but the prefix ($pfx) was specified."
		echo "* "
		echo "* Please re-run ./configure again with the correct $pkg prefix"
		echo "* (or specify no prefix at all to enable auto-detection)."
		echo "* "
		exit 1
	else
		$define=`\$PKGCONFIG $pkg $args 2>/dev/null`
	fi
else
	$define=`\$PKGCONFIG $pkg $args 2>/dev/null`
fi
EOF
}

# 
# Variant of MkExecOutput() which warns when binary exists multiple
# times in the $PATH. If binary exists once, set $MK_EXEC_UNIQUE="Yes".
# 
sub MkExecOutputUnique
{
	my ($bin, $args, $define) = @_;

	if ($Cache) {
		print << "EOF";
MK_EXEC_FOUND="No"
MK_CACHED="No"
MK_EXEC_UNIQUE="No"
MK_EXEC_FOUND_PATH=""
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/exec-$define" ]; then
		$define=`cat \${cache}/exec-$define`
		MK_EXEC_FOUND=`cat \${cache}/exec-found-$define`
		MK_EXEC_FOUND_PATH=`cat \${cache}/exec-found-path-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	$define=""
	for path in `echo \$PATH | sed 's/:/ /g'`; do
		if [ -e "\${path}/$bin" ]; then
			if [ "\$MK_EXEC_FOUND" = "Yes" ]; then
				echo "yes."
				echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)"
				echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)" >> config.log
				break
			fi
			$define=`\${path}/$bin $args`
			MK_EXEC_FOUND="Yes"
			MK_EXEC_FOUND_PATH="\${path}/$bin"
		fi
	done
	if [ "\${cache}" != "" ]; then
		echo "\$$define" > \${cache}/exec-$define
		echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
		echo \$MK_EXEC_FOUND_PATH > \${cache}/exec-found-path-$define
	fi
fi
EOF
	} else {
		print << "EOF";
MK_EXEC_FOUND="No"
MK_CACHED="No"
MK_EXEC_UNIQUE="No"
MK_EXEC_FOUND_PATH=""
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -e "\${path}/$bin" ]; then
		if [ "\$MK_EXEC_FOUND" = "Yes" ]; then
			echo "yes."
			echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)"
			echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)" >> config.log
			break
		fi
		$define=`\${path}/$bin $args`
		MK_EXEC_FOUND="Yes"
		MK_EXEC_FOUND_PATH="\${path}/$bin"
	fi
done
EOF
	}
}

# Write contents of a file into variable "$define".
# Set an empty string and $MK_FILE_FOUND="No" if the file is not found.
sub MkFileOutput
{
	my ($file, $define) = @_;

	print << "EOF";
MK_FILE_FOUND="No"
if [ -e "$file" ]; then
	$define="`cat $file`"
	MK_FILE_FOUND="Yes"
else
	$define=""
fi
EOF
}

# Return the absolute path name of a binary into a variable.
# Set an empty string if the binary is not found.
sub Which
{
	my ($bin, $args, $define) = @_;

	return << "EOF";
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -e "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
		break
	fi
done
EOF
}

sub MkDefine
{
	my ($arg, $val) = @_;
	print "$arg=\"$val\"\n";
}

sub MkAppend
{
	my ($arg, $val) = @_;
	print "$arg=\"\${$arg} $val\"\n";
}

sub MkSetTrue
{
	my ($arg) = @_;
	print "$arg=\"yes\"\n";
}

sub MkSetFalse
{
	my ($arg) = @_;
	print "$arg=\"no\"\n";
}

sub MkAppend
{
	my ($arg, $val) = @_;
	print "$arg=\"\${$arg} $val\"\n";
}

sub MkPrint
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo "$msg"
echo "$msg" >> config.log
EOF
}

sub MkPrintN
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
\$ECHO_N "$msg"
\$ECHO_N "$msg" >> config.log
EOF
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
				MkPrint("*");
				MkPrint("* Minimum required version is $ver (found \$$verDefn); skipping.");
				MkPrint("*");
			MkEndif;
		} else {
			MkDefine('MK_VERSION_OK', 'yes');
		}
	MkElse;
		MkIfNE($pfx, '');
			MkPrint("no (not in $pfx)");
		MkElse;
			MkPrint("no");
		MkEndif;
		MkDefine('MK_VERSION_OK', 'no');
	MkEndif;

	MkIfEQ('${MK_VERSION_OK}', 'yes');
}

sub MkIfVersionOK
{
	MkIfEQ('${MK_VERSION_OK}', 'yes');
}

sub MkNotFound
{
	my $pfx = shift;

	MkIfNE($pfx, '');
		MkPrint("no (not in $pfx)");
	MkElse;
		MkPrint("no");
	MkEndif;
}

sub Log
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;							# Escape quotes
	return "echo \"$msg\" >> config.log\n";
}

sub MkFail
{
	my $msg = shift;
    
	$msg =~ s/["]/\"/g;							# Escape quotes
	print << "EOF";
echo \"$msg\"
exit 1
EOF
}

sub MKSave
{
    my $var = shift;
    my $s = '';
   
	$s = "echo \"$var=\$$var\" >> Makefile.config\n";
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
	foreach my $var (keys %MkDefinesToSave) {
		print << "EOF";
echo "$var=\$$var" >>Makefile.config
echo "mdefs[\\"$var\\"] = \\"\$$var\\"" >>$OutputLUA
EOF
	}
}

sub MkSaveUndef
{
	foreach my $var (@_) {
		if ($OutputHeaderFile) {
			print "echo \"#undef $var\" >>$OutputHeaderFile\n";
		}
		if ($OutputHeaderDir) {
			my $include = $OutputHeaderDir.'/'.lc($var).'.h';
			print "echo \"#undef $var\" >$include\n";
		}
		if ($OutputLUA) {
			print << "EOF";
echo "hdefs[\\"$var\\"] = nil" >>$OutputLUA
EOF
		}
	}
}

sub MkSaveDefine
{
	foreach my $var (@_) {
		if ($OutputHeaderFile) {
			print << "EOF";
echo "#ifndef $var" >> $OutputHeaderFile
echo "#define $var \\"\$$var\\"" >> $OutputHeaderFile
echo "#endif" >> $OutputHeaderFile
EOF
		}
		if ($OutputHeaderDir) {
			my $include = $OutputHeaderDir.'/'.lc($var).'.h';
			print << "EOF";
echo "#ifndef $var" > $include
echo "#define $var \\"\$$var\\"" >> $include
echo "#endif" >> $include
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
echo "#ifndef $var" >> $OutputHeaderFile
echo "#define $var \$$var" >> $OutputHeaderFile
echo "#endif" >> $OutputHeaderFile
EOF
		}
		if ($OutputHeaderDir) {
			my $include = $OutputHeaderDir.'/'.lc($var).'.h';
			print << "EOF";
echo "#ifndef $var" > $include
echo "#define $var \$$var" >> $include
echo "#endif" >> $include
EOF
		}
		print << "EOF";
echo "hdefs[\\"$var\\"] = \$$var" >>$OutputLUA
EOF
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

sub TryCompile
{
	my ($define, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/ctest-$define" ]; then
		$define=`cat \${cache}/ctest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/ctest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.c
$code
EOT
	echo "\$CC \$CFLAGS \$TEST_CFLAGS -o \$testdir/conftest conftest.c" >>config.log
	\$CC \$CFLAGS \$TEST_CFLAGS -o \$testdir/conftest conftest.c 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.c
$code
EOT
echo "\$CC \$CFLAGS \$TEST_CFLAGS -o \$testdir/conftest conftest.c" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS -o \$testdir/conftest conftest.c 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSetTrue($define);
		MkSaveDefine($define);
	MkElse;
		MkPrint('no');
		MkSetFalse($define);
		MkSaveUndef($define);
	MkEndif;

	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
EOF
	}
	print "rm -f conftest.c \$testdir/conftest\$EXECSUFFIX\n";
}

sub BeginTestHeaders
{
	MkDefine('TEST_CFLAGS_ORIG', '${TEST_CFLAGS}');
	MkDefine('TEST_HEADERS', 'Yes');
}

sub EndTestHeaders
{
	MkDefine('TEST_CFLAGS', '${TEST_CFLAGS_ORIG}');
	MkDefine('TEST_HEADERS', '');
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
MK_VERSION_OK="no"
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
	MK_VERSION_OK="yes";
elif [ \$MK_VERSION_MAJOR -eq $verSpec[0] ]; then
	if [ "\$MK_VERSION_MINOR" = "" ]; then
		MK_VERSION_OK="yes"
	else
		if [ \$MK_VERSION_MINOR -gt $verSpec[1] ]; then
			MK_VERSION_OK="yes";
		elif [ \$MK_VERSION_MINOR -eq $verSpec[1] ]; then
			if [ "\$MK_VERSION_MICRO" = "" ]; then
				MK_VERSION_OK="yes"
			else
				if [ \$MK_VERSION_MICRO -ge $verSpec[2] ]; then
					MK_VERSION_OK="yes"
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
MK_VERSION_OK="no"
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
	MK_VERSION_OK="yes";
elif [ \$MK_VERSION_MAJOR -eq $verSpec[0] ]; then
	if [ "\$MK_VERSION_MINOR" = "" ]; then
		MK_VERSION_OK="yes"
	else
		if [ \$MK_VERSION_MINOR -ge $verSpec[1] ]; then
			MK_VERSION_OK="yes"
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
MK_VERSION_OK="no"
if [ \$MK_VERSION_MAJOR -gt $verSpec[0] ]; then
	MK_VERSION_OK="yes";
elif [ \$MK_VERSION_MAJOR -ge $verSpec[0] ]; then
	MK_VERSION_OK="yes";
fi
EOF
	}
}

sub DetectHeaderC
{
	my $def = shift;

	print "echo > conftest.c\n";
	while (my $hdr = shift) {
		print << "EOF";
echo "#include $hdr" >> conftest.c
EOF
	}
	print << 'EOF';
echo "int main (int argc, char *argv[]) { return (0); }" >> conftest.c
EOF
	print << 'EOF';
MK_COMPILE_STATUS="OK"
echo "$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest conftest.c" >>config.log
$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest conftest.c 2>>config.log
if [ $? != 0 ]; then
	echo "-> failed ($?)" >> config.log
	MK_COMPILE_STATUS="FAIL($?)"
fi
rm -f conftest.c $testdir/conftest$EXECSUFFIX
EOF
	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkSetTrue($def);
		MkSaveDefine($def);
		MkIf('"${TEST_HEADERS}" = "Yes"');
			MkDefine('TEST_CFLAGS', "\${TEST_CFLAGS} -D$def");
		MkEndif;
	MkElse;
		MkSetFalse($def);
		MkSaveUndef($def);
	MkEndif;
}

sub MkSaveCompileSuccess ($)
{
	my $define = shift;
		
	MkSetTrue($define);
	MkSaveMK($define);
	MkSaveDefine($define);
}

sub MkSaveCompileFailed ($)
{
	my $define = shift;
		
	MkSetFalse($define);
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

	print << "EOF";
MK_COMPILE_STATUS="OK"
MK_RUN_STATUS="OK"
cat << EOT > conftest.c
$code
EOT
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		print '(cd $testdir && ./conftest$EXECSUFFIX) >> config.log', "\n";
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no (test program failed)');
			MkDefine('MK_RUN_STATUS', 'FAIL(\$?)');
			MkSaveCompileFailed($define);
		MkEndif;
	MkElse;
		MkPrint('no (compilation failed)');
		MkDefine('MK_RUN_STATUS', 'FAIL(\$?)');
		MkSaveCompileFailed($define);
	MkEndif;
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

	print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.cpp
$code
EOT
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		print '(cd $testdir && ./conftest$EXECSUFFIX) >> config.log', "\n";
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no (test program failed)');
			MkSaveCompileFailed($define);
		MkEndif;
	MkElse;
		MkPrint('no (compilation failed)');
		MkSaveCompileFailed($define);
	MkEndif;
}

sub TryCompileFlagsC
{
	my ($define, $flags, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/ctest-$define" ]; then
		$define=`cat \${cache}/ctest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/ctest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.c
$code
EOT
	echo "\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c" >>config.log
	\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.c
$code
EOT
echo "\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;
	
	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
EOF
	}
	print "rm -f conftest.c \$testdir/conftest$EXECSUFFIX\n";
}

sub TryCompileFlagsCXX
{
	my ($define, $flags, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/cxxtest-$define" ]; then
		$define=`cat \${cache}/cxxtest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/cxxtest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.cpp
$code
EOT
	echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp -lstdc++" >>config.log
	\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp -lstdc++ 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.cpp
$code
EOT
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp -lstdc++" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp -lstdc++ 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/cxxtest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/cxxtest-status-$define
fi
EOF
	}
	print "rm -f conftest.cpp \$testdir/conftest\$EXECSUFFIX\n";
}

#
# Compile a test C program. If compilation fails, the test fails. The
# test program is never executed.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkCompileC
{
	my ($define, $cflags, $libs, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/ctest-$define" ]; then
		$define=`cat \${cache}/ctest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/ctest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.c
$code
EOT
	echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs" >>config.log
	\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.c
$code
EOT
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
EOF
	}
	print "rm -f conftest.c \$testdir/conftest\$EXECSUFFIX\n";
}

#
# Compile a test Objective-C program. If compilation fails, the test fails.
# The test program is never executed.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkCompileOBJC
{
	my ($define, $cflags, $libs, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/ctest-$define" ]; then
		$define=`cat \${cache}/ctest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/ctest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.m
$code
EOT
	echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -x objective-c -o \$testdir/conftest conftest.m $libs" >>config.log
	\$CC \$CFLAGS \$TEST_CFLAGS $cflags -x objective-c -o \$testdir/conftest conftest.m $libs 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.m
$code
EOT
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -x objective-c -o \$testdir/conftest conftest.m $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -x objective-c -o \$testdir/conftest conftest.m $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
EOF
	}
	print "rm -f conftest.m \$testdir/conftest\$EXECSUFFIX\n";
}

#
# Compile a test C++ program. If compilation fails, the test fails. The
# test program is never executed.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkCompileCXX
{
	my ($define, $cxxflags, $libs, $code) = @_;

	if ($Cache) {
		print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/cxxtest-$define" ]; then
		$define=`cat \${cache}/cxxtest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/cxxtest-status-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat << EOT > conftest.cpp
$code
EOT
	echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs" >>config.log
	\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	} else {
		print << "EOF";
MK_COMPILE_STATUS="OK"
cat << EOT > conftest.cpp
$code
EOT
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	MK_COMPILE_STATUS="FAIL(\$?)"
fi
EOF
	}

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

	if ($Cache) {
		print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/cxxtest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/cxxtest-status-$define
fi
EOF
	}
	print "rm -f conftest.cpp \$testdir/conftest\$EXECSUFFIX\n";
}

#
# Run a test Perl script.
#
# Sets $define to "yes" or "no" and saves it to both MK and C defines.
#
sub MkRunPerl
{
	my $define = shift;
	my $args = shift;
	my $code = shift;

	$code =~ s/\$/\\\$/g;

	print << "EOF";
cat << EOT > \$testdir/conftest.pl
$code
EOT
(cd \$testdir && perl conftest.pl) >> config.log
EOF
	MkIf('"$?" = "0"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no (script failed)');
		MkSaveCompileFailed($define);
	MkEndif;
	print 'rm -f $testdir/conftest.pl', "\n";
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

BEGIN
{
    require Exporter;
    $| = 1;
    $^W = 0;

    @ISA = qw(Exporter);
    @EXPORT = qw($Cache $OutputLUA $OutputHeaderFile $OutputHeaderDir $LUA $EmulOS $EmulOSRel $EmulEnv %TESTS %DESCR %URL MkExecOutput MkExecOutputPfx MkExecPkgConfig MkExecOutputUnique MkFileOutput Which MkFail MKSave TryCompile MkCompileC MkCompileOBJC MkCompileCXX MkCompileAndRunC MkCompileAndRunCXX TryCompileFlagsC TryCompileFlagsCXX Log MkDefine MkSetTrue MkSetFalse MkAppend MkBreak MkIf MkIfCmp MkIfEQ MkIfNE MkIfTrue MkIfFalse MkIfTest MkIfExists MkIfFile MkIfDir MkCaseIn MkEsac MkCaseBegin MkCaseEnd MkElif MkElse MkEndif MkSaveMK MkSaveMK_Commit MkSaveDefine MkSaveDefineUnquoted MkSaveUndef MkSave MkSaveIfTrue MkPrint MkPrintN MkIfFound MkIfVersionOK MkNotFound PmComment PmIf PmEndif PmIfHDefined PmDefineBool PmDefineString PmIncludePath PmLibPath PmBuildFlag PmLink DetectHeaderC BeginTestHeaders EndTestHeaders MkTestVersion MkEmulWindows MkEmulWindowsSYS MkEmulUnavail MkEmulUnavailSYS);
}

;1
