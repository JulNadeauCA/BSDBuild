# vim:ts=4
#
# Copyright (c) 2002-2009 Hypertriton, Inc. <http://hypertriton.com/>
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

our $OutputLUA = 'configure.lua';
our $LUA = undef;
our $EmulOS = undef;
our $EmulOSRel = undef;
our $EmulEnv = undef;


#
# Bourne instructions.
#
sub MkIf { print 'if [ ',shift,' ]; then',"\n"; }
sub MkElif { print 'elif [ ',shift,' ]; then',"\n"; }
sub MkElse { print 'else',"\n"; }
sub MkEndif { print 'fi;',"\n"; }

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
		if [ -x "\${path}/$bin" ]; then
			if [ -f "\${path}/$bin" ]; then
				$define=`\${path}/$bin $args`
				MK_EXEC_FOUND="Yes"
				break
			fi
		fi
	done
	if [ "\${cache}" != "" ]; then
		echo "\$$define" > \${cache}/exec-$define
		echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
	fi
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
		if [ -x "\${path}/$bin" ]; then
			if [ -f "\${path}/$bin" ]; then
				if [ "\$MK_EXEC_FOUND" = "Yes" ]; then
					echo "yes."
					echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)"
					echo "* Warning: Multiple '$bin' exist in PATH (using \$MK_EXEC_FOUND_PATH)" >> config.log
					break;
				fi
				$define=`\${path}/$bin $args`
				MK_EXEC_FOUND="Yes"
				MK_EXEC_FOUND_PATH="\${path}/$bin"
			fi
		fi
	done
	if [ "\${cache}" != "" ]; then
		echo "\$$define" > \${cache}/exec-$define
		echo \$MK_EXEC_FOUND > \${cache}/exec-found-$define
		echo \$MK_EXEC_FOUND_PATH > \${cache}/exec-found-path-$define
	fi
fi
EOF
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
	if [ -x "\${path}" ]; then
		if [ -e "\${path}/$bin" ]; then
			$define=`\${path}/$bin $args`
			break
		fi
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
		print << "EOF";
echo "$var=\$$var" >>Makefile.config
echo "mdefs[\\"$var\\"] = \\"\$$var\\"" >>$OutputLUA
EOF
	}
}

sub MkSaveUndef
{
	foreach my $var (@_) {
		my $include = 'config/'.lc($var).'.h';
		print << "EOF";
echo "#undef $var" >$include
echo "hdefs[\\"$var\\"] = nil" >>$OutputLUA
EOF
	}
}

sub MkSaveDefine
{
	foreach my $var (@_) {
		my $include = 'config/'.lc($var).'.h';
		print << "EOF";
echo "#ifndef $var" > $include
echo "#define $var \\"\$$var\\"" >> $include
echo "#endif" >> $include
echo "hdefs[\\"$var\\"] = \\"\$$var\\"" >>$OutputLUA
EOF
	}
}

sub TryCompile
{
	my ($define, $code) = @_;

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

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkDefine($define, 'yes');
		MkSaveDefine($define);
	MkElse;
		MkPrint('no');
		MkDefine($define, 'no');
		MkSaveUndef($define);
	MkEndif;
	
print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
rm -f conftest.c \$testdir/conftest\$EXECSUFFIX
EOF
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
	my ($name, $verDef, $ver) = @_;
	if ($ver =~ /^\?(.+)$/) {
		$nofail = 1;
		$ver = $1;
	} else {
		$nofail = 0;
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
		if (!$nofail) {
			print << "EOF";
if [ "\$MK_VERSION_OK" != "yes" ]; then
	echo "*"
	echo "* Found $name version \$MK_VERSION_MAJOR.\$MK_VERSION_MINOR.\$MK_VERSION_MICRO."
	echo "* This software requires at least version $ver."
	echo "* Please upgrade $name and try again."
	echo "*"
	exit 1
fi
EOF
		}
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
		if (!$nofail) {
			print << "EOF";
if [ "\$MK_VERSION_OK" != "yes" ]; then
	echo "*"
	echo "* Found $name version \$MK_VERSION_MAJOR.\$MK_VERSION_MINOR."
	echo "* This software requires at least version $ver."
	echo "* Please upgrade $name and try again."
	echo "*"
	exit 1
fi
EOF
		}
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
		if (!$nofail) {
			print << "EOF";
if [ "\$MK_VERSION_OK" != "yes" ]; then
	echo "*"
	echo "* Found $name version \$MK_VERSION_MAJOR."
	echo "* This software requires at least version $ver."
	echo "* Please upgrade $name and try again."
	echo "*"
	exit 1
fi
EOF
		}
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
		MkDefine($def, 'yes');
		MkSaveDefine($def);
		MkIf('"${TEST_HEADERS}" = "Yes"');
			MkDefine('TEST_CFLAGS', "\${TEST_CFLAGS} -D$def");
		MkEndif;
	MkElse;
		MkDefine($def, 'no');
		MkSaveUndef($def);
	MkEndif;
}

sub MkSaveCompileSuccess ($)
{
	my $define = shift;
		
	MkDefine($define, 'yes');
	MkSaveMK($define);
	MkSaveDefine($define);
}

sub MkSaveCompileFailed ($)
{
	my $define = shift;
		
	MkDefine($define, 'no');
	MkSaveMK($define);
	MkSaveUndef($define);
}

#
# Compile and run a test C program. If the program returns a non-zero
# exit code, the test fails.
#
# Sets $define to "yes" or "no" and saves it to both Makefile.config and
# ./config/.
#
sub MkCompileAndRunC
{
	my ($define, $cflags, $libs, $code) = @_;

	print << "EOF";
MK_CACHED="No"
MK_COMPILE_STATUS="OK"
MK_RUN_STATUS="OK"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/ctest-$define" ]; then
		$define=`cat \${cache}/ctest-$define`
		MK_COMPILE_STATUS=`cat \${cache}/ctest-status-$define`
		MK_RUN_STATUS=`cat \${cache}/ctest-runstatus-$define`
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
print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
	echo \$MK_RUN_STATUS > \${cache}/ctest-runstatus-$define
fi
rm -f conftest.c \$testdir/conftest$EXECSUFFIX
EOF
}

#
# Compile and run a test C++ program. If the program returns a non-zero
# exit code, the test fails.
#
# Sets $define to "yes" or "no" and saves it to both Makefile.config and
# ./config/.
#
sub MkCompileAndRunCXX
{
	my ($define, $cxxflags, $libs, $code) = @_;

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

print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/cxxtest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/cxxtest-status-$define
fi
rm -f conftest.cpp \$testdir/conftest\$EXECSUFFIX
EOF
}

sub TryCompileFlagsC
{
	my ($define, $flags, $code) = @_;

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

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;
	
print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
rm -f conftest.c \$testdir/conftest$EXECSUFFIX
EOF
}

sub TryCompileFlagsCXX
{
	my ($define, $flags, $code) = @_;

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
	echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp" >>config.log
	\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp 2>>config.log
	if [ \$? != 0 ]; then
		echo "-> failed (\$?)" >> config.log
		MK_COMPILE_STATUS="FAIL(\$?)"
	fi
fi
EOF
	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/cxxtest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/cxxtest-status-$define
fi
rm -f conftest.cpp \$testdir/conftest\$EXECSUFFIX
EOF
}

#
# Compile a test C program. If compilation fails, the test fails. The
# test program is never executed.
#
# Sets $define to "yes" or "no" and saves it to both Makefile.config and
# ./config/.
#
sub MkCompileC
{
	my ($define, $cflags, $libs, $code) = @_;

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

	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/ctest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/ctest-status-$define
fi
rm -f conftest.c \$testdir/conftest\$EXECSUFFIX
EOF
}

#
# Compile a test C++ program. If compilation fails, the test fails. The
# test program is never executed.
#
# Sets $define to "yes" or "no" and saves it to both Makefile.config and
# ./config/.
#
sub MkCompileCXX
{
	my ($define, $cxxflags, $libs, $code) = @_;

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
	MkIf('"${MK_COMPILE_STATUS}" = "OK"');
		MkPrint('yes');
		MkSaveCompileSuccess($define);
	MkElse;
		MkPrint('no');
		MkSaveCompileFailed($define);
	MkEndif;

print << "EOF";
if [ "\${cache}" != "" ]; then
	echo "\$$define" > \${cache}/cxxtest-$define
	echo \$MK_COMPILE_STATUS > \${cache}/cxxtest-status-$define
fi
rm -f conftest.cpp \$testdir/conftest\$EXECSUFFIX
EOF
}

#
# Run a test Perl script.
#
# Sets $define to "yes" or "no" and saves it to both Makefile.config
# and ./config/.
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

BEGIN
{
    require Exporter;
    $| = 1;
    $^W = 0;

    @ISA = qw(Exporter);
    @EXPORT = qw($OutputLUA $LUA $EmulOS $EmulOSRel $EmulEnv %TESTS %DESCR MkExecOutput MkExecOutputUnique MkFileOutput Which MkFail MKSave TryCompile MkCompileC MkCompileCXX MkCompileAndRunC MkCompileAndRunCXX TryCompileFlagsC TryCompileFlagsCXX Log MkDefine MkAppend MkIf MkElif MkElse MkEndif MkSaveMK MkSaveDefine MkSaveUndef MkPrint MkPrintN PmComment PmIf PmEndif PmIfHDefined PmDefineBool PmDefineString PmIncludePath PmLibPath PmBuildFlag PmLink DetectHeaderC BeginTestHeaders EndTestHeaders MkTestVersion);
}

;1
