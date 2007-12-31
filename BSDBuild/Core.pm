# vim:ts=4
#
# Copyright (c) 2002-2007 Hypertriton, Inc. <http://hypertriton.com/>
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

our $LUA = undef;

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
	print {$LUA} "-- $com\n";
}
sub PmDefineBool {
	my $def = shift;
	print {$LUA} << "EOF";
table.insert(package.defines,{"$def"})
EOF
}
sub PmDefineString {
	my ($def, $val) = @_;
	print {$LUA} << "EOF";
table.insert(package.defines,{"$def=$val"})
EOF
}
sub PmIncludePath {
	my $path = shift;
	print {$LUA} << "EOF";
table.insert(package.includepaths,{"$path"})
EOF
}
sub PmLibPath {
	my $path = shift;
	print {$LUA} << "EOF";
table.insert(package.libpaths,{"$path"})
EOF
}
sub PmBuildFlag {
	my $flag = shift;
	print {$LUA} << "EOF";
table.insert(package.buildflags,{"$flag"})
EOF
}

# Read the output of a program into a variable.
# Set an empty string if the binary is not found.
sub MkExecOutput
{
	my ($bin, $args, $define) = @_;

	print << "EOF";
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -x "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
	fi
done
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
	if [ -x "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
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
echo "mdefs[\\"$var\\"] = \\"\$$var\\"" >>configure.lua
EOF
	}
}

sub MkSaveUndef
{
	foreach my $var (@_) {
		my $include = 'config/'.lc($var).'.h';
		print << "EOF";
echo "#undef $var" >$include
echo "hdefs[\\"$var\\"] = nil" >>configure.lua
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
echo "hdefs[\\"$var\\"] = \\"\$$var\\"" >>configure.lua
EOF
	}
}

sub TryCompile
{
	my $def = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << 'EOF';
compile="ok"
echo "$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest conftest.c" >>config.log
$CC $CFLAGS $TEST_CFLAGS -o $testdir/conftest conftest.c 2>>config.log
if [ $? != 0 ]; then
	echo "-> failed ($?)" >> config.log
	compile="failed"
fi
rm -f $testdir/conftest conftest.c
EOF

		MkIf('"${compile}" = "ok"');
			MkPrint('yes');
			MkDefine($def, 'yes');
			MkSaveDefine($def);
		MkElse;
			MkPrint('no');
			MkDefine($def, 'no');
			MkSaveUndef($def);
		MkEndif;
	}
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
	my $define = shift;
	my $cflags = shift;
	my $libs = shift;
	my $code = shift;

	print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
	print << "EOF";
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs 2>>config.log
EOF
	MkIf('$? != 0');
		MkPrint('no (compile failed)');
		MkDefine('compile', 'failed');
		MkSaveCompileFailed($define);
	MkElse;
		MkDefine('compile', 'ok');
		print '(cd $testdir && ./conftest) >> config.log', "\n";
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no (exec failed)');
			MkSaveCompileFailed($define);
		MkEndif;
	MkEndif;
	print 'rm -f $testdir/conftest conftest.c', "\n";
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
	my $define = shift;
	my $cxxflags = shift;
	my $libs = shift;
	my $code = shift;

	print << "EOF";
cat << EOT > conftest.cpp
$code
EOT
EOF
	print << "EOF";
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs 2>>config.log
EOF
	MkIf('$? != 0');
		MkPrint('no (compile failed)');
		MkDefine('compile', 'failed');
		MkSaveCompileFailed($define);
	MkElse;
		MkDefine('compile', 'ok');
		print '(cd $testdir && ./conftest) >> config.log', "\n";
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no (exec failed)');
			MkSaveCompileFailed($define);
		MkEndif;
	MkEndif;
	print 'rm -f $testdir/conftest conftest.cpp', "\n";
}

sub TryCompileFlagsC
{
	my $define = shift;
	my $flags = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << "EOF";
compile="ok"
echo "\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $flags -o \$testdir/conftest conftest.c 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	compile="failed"
fi
rm -f \$testdir/conftest conftest.c
EOF
		MkIf('"${compile}" = "ok"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no');
			MkSaveCompileFailed($define);
		MkEndif;
	}
}

sub TryCompileFlagsCXX
{
	my $define = shift;
	my $flags = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.cpp
$code
EOT
EOF
		print << "EOF";
compile="ok"
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $flags -o \$testdir/conftest conftest.cpp 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	compile="failed"
fi
rm -f \$testdir/conftest conftest.cpp
EOF
		MkIf('"${compile}" = "ok"');
			MkPrint('yes');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no');
			MkSaveCompileFailed($define);
		MkEndif;
	}
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
	my $define = shift;
	my $cflags = shift;
	my $libs = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << "EOF";
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o \$testdir/conftest conftest.c $libs 2>>config.log
EOF
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkDefine('compile', 'ok');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no');
			MkDefine('compile', 'failed');
			MkSaveCompileFailed($define);
		MkEndif;

		print 'rm -f $testdir/conftest conftest.c', "\n";
	}
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
	my $define = shift;
	my $cxxflags = shift;
	my $libs = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.cpp
$code
EOT
EOF
		print << "EOF";
echo "\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs" >>config.log
\$CXX \$CXXFLAGS \$TEST_CXXFLAGS $cxxflags -o \$testdir/conftest conftest.cpp $libs 2>>config.log
EOF
		MkIf('"$?" = "0"');
			MkPrint('yes');
			MkDefine('compile', 'ok');
			MkSaveCompileSuccess($define);
		MkElse;
			MkPrint('no');
			MkDefine('compile', 'failed');
			MkSaveCompileFailed($define);
		MkEndif;

		print 'rm -f $testdir/conftest conftest.cpp', "\n";
	}
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
    @EXPORT = qw($LUA %TESTS %DESCR MkExecOutput Which MkFail MKSave TryCompile MkCompileC MkCompileCXX MkCompileAndRunC MkCompileAndRunCXX TryCompileFlagsC TryCompileFlagsCXX Log MkDefine MkAppend MkIf MkElif MkElse MkEndif MkSaveMK MkSaveDefine MkSaveUndef MkPrint MkPrintN PmComment PmDefineBool PmDefineString PmIncludePath PmLibPath PmBuildFlag);
}

;1
