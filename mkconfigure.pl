#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2001-2012 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
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
#
use BSDBuild::Core;
use BSDBuild::Builtins;
use Getopt::Long;

my $Verbose = 0;
my %Fns = (
	'package'		=> \&package,
	'version'		=> \&version,
	'release'		=> \&release,
	'register'		=> \&register,
	'register_section'	=> \&register_section,
	'test'			=> \&test,
	'check'			=> \&test,		# <2.8 compat
	'require'		=> \&test_require,
	'test_dir'		=> \&test_dir,
	'mdefine'		=> \&mdefine,
	'mappend'		=> \&mappend,
	'hdefine'		=> \&hdefine,
	'hdefine_unquoted'	=> \&hdefine_unquoted,
	'hundef'		=> \&hundef,
	'c_define'		=> \&c_define,
	'c_incdir'		=> \&c_incdir,
	'c_incprep'		=> \&c_incprep,
	'c_libdir'		=> \&c_libdir,
	'c_option'		=> \&c_option,
	'ld_option'		=> \&ld_option,
	'c_extra_warnings'	=> \&c_extra_warnings,
	'c_fatal_warnings'	=> \&c_fatal_warnings,
	'c_no_secure_warnings'	=> \&c_no_secure_warnings,
	'c_incdir_config'	=> \&c_incdir_config,
	'c_include_config'	=> \&c_include_config,
	'config_script'		=> \&config_script,
	'config_guess'		=> \&config_guess,
	'check_header'		=> \&check_header,
	'check_header_opts'	=> \&check_header_opts,
	'check_func'		=> \&check_func,
	'check_func_opts'	=> \&check_func_opts,
	'check_perl_module'	=> \&check_perl_module,
	'require_perl_module'	=> \&require_perl_module,
	'default_dir'		=> \&default_dir,
);

$INSTALLDIR = '%PREFIX%/share/bsdbuild';
my @Help = ();
my $ConfigGuess = 'mk/config.guess';
my @TestDirs = ("$INSTALLDIR/BSDBuild");
my %EmulDepsTested = ();

# Specify software package name
sub package
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('PACKAGE', $val);
	MkSaveMK('PACKAGE');
	MkSaveDefine('PACKAGE');
}

# Specify software package version
sub version
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('VERSION', $val);
	MkSaveMK('VERSION');
	MkSaveDefine('VERSION');
}

# Specify software package release name
sub release
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('RELEASE', $val);
	MkSaveMK('RELEASE');
	MkSaveDefine('RELEASE');
}

# Directives used in first pass; no-ops as script directives
sub register { }
sub register_section { }
sub config_guess { }
sub c_incdir_config { }
sub c_include_config { }

# Check for a header file
sub check_header
{
	foreach my $hdrFile (@_) {
		$hdrDef = uc($hdrFile);
		$hdrDef =~ s/[\\\/\.]/_/g;
		$hdrDef = 'HAVE_'.$hdrDef;

		MkPrintN("checking for <$hdrFile> ($hdrDef)...");
		MkCompileC $hdrDef, '', '', << "EOF";
#include <$hdrFile>
int main (int argc, char *argv[]) { return (0); }
EOF
	}
}

# Check for a header file, with specific CFLAGS/LIBS.
sub check_header_opts
{
	my $cflags = shift;
	my $libs = shift;

	foreach my $hdrFile (@_) {
		$hdrDef = uc($hdrFile);
		$hdrDef =~ s/[\\\/\.]/_/g;
		$hdrDef = 'HAVE_'.$hdrDef;

		MkPrintN("checking for <$hdrFile>...");
		MkCompileC $hdrDef, $cflags, $libs, << "EOF";
#include <$hdrFile>
int main (int argc, char *argv[]) { return (0); }
EOF
	}
}

# Check for a function
sub check_func
{
	foreach my $funcList (@_) {
	    $funcDef = uc($funcList);
	    $funcDef =~ s/[\\\/\.]/_/g;
	    $funcDef = 'HAVE_'.$funcDef;

	    MkPrintN("checking for $funcList()...");
	    MkDefine('TEST_CFLAGS', '-Wall');		# Avoid failing on "conflicting types blah"
	    MkCompileC $funcDef, '', '', << "EOF";
#ifdef __STDC__
# include <limits.h>
#else
# include <assert.h>
#endif

#undef $funcList

#ifdef __cplusplus
extern "C"
#endif

char $funcList();
#if defined __stub_$funcList || defined __stub___$funcList
choke me
#endif

int main() {
    return $funcList();
    ;
    return 0;
}
EOF
	}
}

# Check for a Perl module.
sub check_perl_module
{
    	my $modname = shift;
	my $define = 'HAVE_'.uc($modname);
	$define =~ s/::/_/;

	MkPrintN("checking for Perl module $modname...");
	print << "EOF";
$define="No"
MK_CACHED="No"
if [ "\${cache}" != "" ]; then
	if [ -e "\${cache}/perltest-$define" ]; then
		$define=`cat \${cache}/perltest-$define`
		MK_CACHED="Yes"
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat /dev/null | \${PERL} -M$modname 2>/dev/null
	if [ \$? != 0 ]; then
		echo "-> not found (\$?)" >> config.log
		$define="no"
		echo "no"
	else
		echo "-> found" >> config.log
		$define="yes"
		echo "yes"
	fi
fi
EOF

}

# Check for a Perl module and fail if not found.
sub require_perl_module
{
    	my $modname = shift;
	my $define = 'HAVE_'.uc($modname);
	$define =~ s/::/_/;

	check_perl_module($modname);
	
	MkIf "\"\$\{$define\}\" != \"yes\"";
		MkPrint('* ');
		MkPrint("* This software requires the $modname module.");
		MkPrint("* Get it from CPAN (http://cpan.org/).");
		MkPrint('* ');
		MkFail('configure failed!');
	MkEndif;
}

# Specify an alternate installation directory default.
sub default_dir
{
    	my $dir = shift;
	my $default = shift;
	
	if ($dir =~ /^"(.*)"$/) { $dir = $1; }
	if ($default =~ /^"(.*)"$/) { $default = $1; }

	MkIf "\"\$\{${dir}_SPECIFIED\}\" != \"yes\"";
		MkDefine($dir, $default);
		MkSaveDefine($dir);
		MkSaveMK($dir);
	MkEndif;
}

# Check for a function with CFLAGS and LIBS
sub check_func_opts
{
    	my $cflags = shift;
	my $libs = shift;

	foreach my $funcList (@_) {
	    $funcDef = uc($funcList);
	    $funcDef =~ s/[\\\/\.]/_/g;
	    $funcDef = 'HAVE_'.$funcDef;

	    MkPrintN("checking for $funcList()...");
	    MkDefine('TEST_CFLAGS', '-Wall');		# Avoid failing on "conflicting types blah"
	    MkCompileC $funcDef, $cflags, $libs, << "EOF";
#ifdef __STDC__
# include <limits.h>
#else
# include <assert.h>
#endif

#undef $funcList

#ifdef __cplusplus
extern "C"
#endif

char $funcList();
#if defined __stub_$funcList || defined __stub___$funcList
choke me
#endif

int main() {
    return $funcList();
    ;
    return 0;
}
EOF
	}
}

# Add a directory containing extra test modules.
sub test_dir
{
	foreach my $dir (@_) {
		unless (-e $dir) {
			print STDERR "TEST_DIR $dir: $!; ignoring\n";
			next;
		}
		push @TestDirs, $dir;
	}
}

# Execute one of the standard BSDBuild tests.
sub test
{
	my @args = @_;
	my ($t) = shift(@args);
	my $mod = undef;

	foreach my $dir (@TestDirs) {
		my $path = $dir.'/'.$t.'.pm';
		if (-e $path) {
			$mod = $path;
			last;
		}
	}
	if (!defined($mod)) {
		print STDERR "No such test module: $t\n";
		exit (1);
	}
	do($mod);
	if ($@) {
		print STDERR $@;
		exit (1);
	}
	if (exists($DEPS{$t})) {
		foreach my $dep (split(',', $DEPS{$t})) {
			if (!exists($done{$dep})) {
				print STDERR "$t depends on: $dep\n";
				exit(1);
			}
		}
	}
	my $c;
	if ($EmulOS) {
		unless (exists($EMUL{$t}) && defined($EMUL{$t})) {
			print STDERR "Missing EMUL for $t\n";
			exit(1);
		}
		if (exists($EMULDEPS{$t})) {
	 		foreach my $ed (@{$EMULDEPS{$t}}) {
				if (!exists($EmulDepsTested{$ed})) {
					test($ed);
					$EmulDepsTested{$ed} = 1;
				}
			}
		}
		$c = $EMUL{$t};
		@args = ($EmulOS, $EmulOSRel, '');
	} else {
		$c = $TESTS{$t};
	}
	if ($c) {
		MkPrintN("checking for $DESCR{$t}...");
		&$c(@args);
		if ($EmulOS) {
			MkPrintN("ok\n");
		}
	}
	$done{$t} = 1;
}

# Execute one of the standard BSDBuild tests, abort if the test fails.
sub test_require
{
	my ($t, $ver) = @_;
	my $def = 'HAVE_'.uc($t);

	test(@_);
	
	if ($EmulOS) {
		return;
	}

	MkIf "\"\$\{$def\}\" != \"yes\"";
		MkPrint('* ');
		MkPrint("* This software requires $t installed on your system.");
		MkPrint('* ');
		MkFail('configure failed!');
	MkEndif;

	if ($ver) {
		MkIf '"${MK_VERSION_OK}" != "yes"';
			MkPrint('* ');
			MkPrint("* This software requires $t version >= $ver,");
			MkPrint("* please upgrade and try again.");
			MkPrint('* ');
			MkFail('configure failed!');
		MkEndif;
	}
}

# Make environment define
sub mdefine
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveMK($def);
}

# Append to make environment define
sub mappend
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, "\${$def} $val");
	MkSaveMK($def);
}

# Header define
sub hdefine
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefine($def);
}

# Header define unquoted
sub hdefine_unquoted
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefineUnquoted($def);
}
# Header undef
sub hundef
{
	my $def = shift;
	MkSaveUndef($def);
}

# C/C++ define
sub c_define
{
	my $def = shift;

	MkDefine('CFLAGS', '$CFLAGS -D'.$def);
	MkDefine('CXXFLAGS', '$CXXFLAGS -D'.$def);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');
	print {$LUA} "table.insert(package.defines,{\"$def\"})\n";
}

# C/C++ include directory
sub c_incdir
{
	my $dir = shift;
	my $qdir = $dir;

#	if ($dir =~ /^\$/) { $qdir = '\"'.$dir.'\"'; }
	MkDefine('CFLAGS', '$CFLAGS -I'.$qdir);
	MkDefine('CXXFLAGS', '$CXXFLAGS -I'.$qdir);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');

	if ($EmulEnv eq 'vs2005') {
		$dir =~ s/\$SRC/\$\(SolutionDir\)/g;
		$dir =~ s/\$BLD/\$\(SolutionDir\)/g;
	} else {
		$dir =~ s/\$SRC/\.\./g;
		$dir =~ s/\$BLD/\.\./g;
	}
	print {$LUA} "table.insert(package.includepaths,{\"$dir\"})\n";
}

# Include file preprocessing
sub c_incprep
{
	my $dir = shift;

	print << "EOF";
if [ ! -e "$dir" ]; then
	mkdir -p "$dir"
fi
if [ "\${includes}" = "link" ]; then
	\$ECHO_N "* Linking C include files..."
	if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
		(cd \${SRCDIR} && \${PERL} mk/gen-includelinks.pl "\${SRCDIR}" "$dir" 1>>\${BLDDIR}/config.log 2>&1)
	else
		\${PERL} mk/gen-includelinks.pl "\${SRCDIR}" "$dir" 1>>config.log 2>&1
	fi
	if [ \$? != 0 ]; then
		echo "\${PERL} mk/gen-includelinks.pl failed"
		exit 1
	fi
	echo "done"
else
	if [ "\${PERL}" = "" ]; then
		echo "*"
		echo "* The --includes=yes option requires perl, but no perl"
		echo "* interpreter was found. If perl is unavailable, please"
		echo "* please rerun configure with --includes=link instead."
		echo "*"
		exit 1
	fi
	\$ECHO_N "* Preprocessing C include files..."
	if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
		(cd \${SRCDIR} && \${PERL} mk/gen-includes.pl "$dir" 1>>\${BLDDIR}/config.log 2>&1)
	else
		\${PERL} mk/gen-includes.pl "$dir" 1>>config.log 2>&1
	fi
	if [ \$? != 0 ]; then
		echo "\${PERL} mk/gen-includes.pl failed"
		exit 1
	fi
	echo "done"
fi
EOF
}

# C/C++ library directory
sub c_libdir
{
	my $dir = shift;

#	if ($dir =~ /^\$/) { $qdir = '\"'.$dir.'\"'; }
	MkDefine('LIBS', '$LIBS -L'.$dir);
	MkSaveMK('LIBS');

	$dir =~ s/\$SRC/\./g;
	print {$LUA} "table.insert(package.libpaths,{\"$dir\"})\n";
}

# Extra compiler warnings
sub c_extra_warnings
{
	print {$LUA} 'table.insert(package.buildflags,{"extra-warnings"})'."\n";
}

# Fatal warnings
sub c_fatal_warnings
{
	print {$LUA} 'table.insert(package.buildflags,{"extra-warnings"})'."\n";
}

# Disable _CRT_SECURE warnings (win32)
sub c_no_secure_warnings
{
	print {$LUA} << "EOF";
if (windows) then
	table.insert(package.defines,{"_CRT_SECURE_NO_WARNINGS"})
	table.insert(package.defines,{"_CRT_SECURE_NO_DEPRECATE"})
end
EOF
}

# C compiler option
sub c_option
{
	my $opt = shift;

	MkDefine('CFLAGS', '$CFLAGS '.$opt);
	MkDefine('CXXFLAGS', '$CXXFLAGS '.$opt);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');
}

# Linker option
sub ld_option
{
	my $opt = shift;

	MkDefine('LDFLAGS', '$LDFLAGS'.$opt);
	MkSaveMK('LDFLAGS');
}

# Generate a "foo-config" style script.
sub config_script
{
	my ($out, $cflags, $libs) = @_;

	if ($out =~ /^"(.+)"$/) { $out = $1; }
	if ($cflags =~ /^"(.+)"$/) { $cflags = $1; }
	if ($libs =~ /^"(.+)"$/) { $libs = $1; }
	print "config_script_out=\"$out\"\n";
	print "config_script_cflags=\"$cflags\"\n";
	print "config_script_libs=\"$libs\"\n";
	print << 'EOF';
# Avoid breakage with existing trees compiled before BSDBuild 2.8.
if [ -d "$config_script_out" ]; then
	echo "rm -fR $config_script_out"
	rm -fR $config_script_out
fi
if [ "${SRC}" != "" ]; then
	if [ -d "${SRC}/$config_script_out" ]; then
		echo "rm -fR ${SRC}/$config_script_out"
		rm -fR ${SRC}/$config_script_out
	fi
fi
cat << EOT > $config_script_out
#!/bin/sh
# Generated for ${PACKAGE} by BSDBuild %VERSION%.
# <http://bsdbuild.hypertriton.com>

prefix="${PREFIX}"
exec_prefix="${EXEC_PREFIX}"
exec_prefix_set="no"
libdir="${LIBDIR}"

usage="\
Usage: $config_script_out [--prefix[=DIR]] [--exec-prefix[=DIR]] [--version] [--cflags] [--libs]"

if test \$# -eq 0; then
	echo "\${usage}" 1>&2
	exit 1
fi

while test \$# -gt 0; do
	case "\$1" in
	-*=*)
		optarg=\`echo "\$1" | LC_ALL="C" sed 's/[-_a-zA-Z0-9]*=//'\`
		;;
	*)
		optarg=
		;;
	esac

	case \$1 in
	--prefix=*)
		prefix=\$optarg
		if test \$exec_prefix_set = no ; then
			exec_prefix=\$optarg
		fi
		;;
	--prefix)
		echo "\$prefix"
		;;
	--exec-prefix=*)
		exec_prefix=\$optarg
		exec_prefix_set=yes
		;;
	--exec-prefix)
		echo "\$exec_prefix"
		;;
	--version)
		echo "${VERSION}"
		;;
	--cflags)
		echo "$config_script_cflags"
		;;
	--libs | --static-libs)
		echo "$config_script_libs"
		;;
	*)
		echo "\${usage}" 1>&2
		exit 1
		;;
	esac
	shift
done
EOT
EOF
}

#
# End macros
#

# Process REGISTER() in first pass.
sub pass1_register
{
	my ($arg, $descr) = @_;

	if ($arg =~ /\"(.*)\"/) { $arg = $1; }
	if ($descr =~ /\"(.*)\"/) { $descr = $1; }

	my $darg = pack('A' x 25, split('', $arg));
	push @Help, "echo \"    $darg $descr\"";
}

# Process REGISTER_SECTION() in first pass.
sub pass1_register_section
{
	my ($s) = @_;

	if ($s =~ /\"(.*)\"/) { $s = $1; }
	push @Help, "echo \"\"";
	push @Help, "echo \"$s\"";
}

# Process CONFIG_GUESS() in first pass.
sub pass1_config_guess
{
	my ($s) = @_;

	if ($s =~ /\"(.*)\"/) { $s = $1; }
	if ($Verbose) {
		print STDERR "Using config.guess: $s\n";
	}
	$ConfigGuess = $s;
}

# Specify target ./config include directory.
sub pass1_c_incdir_config
{
	my $dir = shift;

	if ($dir) {
		$OutputHeaderDir = $dir;
	} else {
		$OutputHeaderDir = undef;
	}
}

# Specify target monolithic config header file.
sub pass1_c_include_config
{
	my $file = shift;

	if ($file) {
		print << "EOF";
if [ -e "$file" ]; then
	echo "* Overwriting $file"
	rm -f "$file"
fi
EOF
		$OutputHeaderFile = $file;
	} else {
		$OutputHeaderFile = undef;
	}
}

sub Help
{
	my %stdOpts = (
		'--srcdir=p' =>		'Source directory for concurrent build',
		'--build=s' =>		'Host environment for build',
		'--host=s' =>		'Cross-compile for target environment',
		'--byte-order=s' =>	'Byte order for build (LE|BE)',
		'--prefix=p' =>		'Installation base',
		'--exec-prefix=p' =>	'Machine-dependent installation base',
		'--bindir=p' =>		'Executables for common users',
		'--libdir=p' =>		'System libraries',
		'--moduledir=P' =>	'Dynamically loaded modules',
		'--libexecdir=p' =>	'Executables for program use',
		'--datadir=P' =>	'Data files for program use',
		'--statedir=P' =>	'Modifiable single-machine data',
		'--sysconfdir=P' =>	'System configuration files',
		'--localedir=p' =>	'Multi-language support locales',
		'--mandir=p' =>		'Manual page documentation',
		'--testdir=p' =>	'Execute all tests in this directory',
		'--cache=p' =>		'Cache ./configure results in directory',
		'--includes=s' =>	'Preprocess C headers (yes|no|link)',
		
		'--enable-nls' =>	'Multi-language support',
		'--with-gettext' =>	'Use gettext for multi-language',
		'--with-libtool' =>	'Specify path to libtool',
		'--with-manpages' =>	'Generate Unix manual pages',
		'--with-catman' =>	'Install cat files for manual pages',
		'--with-manlinks' =>	'Add manual entries for every function',
		'--with-ctags' =>	'Generate ctags(1) tag files',
		'--with-docs' =>	'Generate printable documentation',
	);
	my %stdDefaults = (
		'--srcdir=p' =>		'.',
		'--build=s' =>		'auto-detect',
		'--host=s' =>		'BUILD',
		'--byte-order=s' =>	'auto-detect',
		'--prefix=p' =>		'/usr/local',
		'--exec-prefix=p' =>	'PREFIX',
		'--bindir=p' =>		'PREFIX/bin',
		'--libdir=p' =>		'PREFIX/lib',
		'--moduledir=P' =>	'PREFIX/lib',
		'--libexecdir=p' =>	'PREFIX/libexec',
		'--datadir=P' =>	'PREFIX/share',
		'--statedir=P' =>	'PREFIX/var',
		'--sysconfdir=P' =>	'PREFIX/etc',
		'--localedir=p' =>	'DATADIR/locale',
		'--mandir=p' =>		'PREFIX/man',
		'--testdir=p' =>	'.',
		'--cache=p' =>		'none',
		'--includes=s' =>	'yes',

		'--enable-nls' =>	'no',
		'--with-gettext' =>	'auto-detect',
		'--with-libtool' =>	'auto-detect',
		'--with-manpages' =>	'yes',
		'--with-catman' =>	'auto-detect',
		'--with-manlinks' =>	'no',
		'--with-ctags' =>	'no',
		'--with-docs' =>	'no',
	);
    
	print << 'EOF';
echo "This configure script was generated by BSDBuild %VERSION%."
echo "<http://bsdbuild.hypertriton.com/>"
echo ""
echo "Usage: ./configure [options]"
echo ""
echo "Standard build options:"
EOF
	foreach my $opt (sort keys %stdOpts) {
		my ($optName, $optSpec) = split('=', $opt);

		if (defined($optSpec) && $optSpec eq 'p') {
			$optName = $optName.'=DIR';
		} elsif (defined($optSpec) && $optSpec eq 'P') {
			$optName = $optName.'=DIR|NONE';
		} elsif (defined($optSpec) && $optSpec eq 's') {
			$optName = $optName.'=STRING';
		}
		my $optFmt = pack('A' x 25, split('', $optName));
		print 'echo "    '.$optFmt.' '.$stdOpts{$opt};
		if (exists($stdDefaults{$opt})) {
			print ' ['.$stdDefaults{$opt}.']';
		}
		print "\"\n";
	}
	print join("\n",@Help),"\n";
	print "exit 1\n";
}

sub Version
{
    print << "EOF";
if [ "${PACKAGE}" != "" ]; then
	echo "BSDBuild %VERSION%, for ${PACKAGE} ${VERSION}"
else
	echo "BSDBuild %VERSION%"
fi
exit 1
EOF
}

#
# BEGIN
#

my $res = GetOptions(
	"verbose" =>		\$Verbose,
	"emul-os=s" =>		\$EmulOS,
	"emul-osrel=s" =>	\$EmulOSRel,
	"emul-env=s" =>		\$EmulEnv,
	"output-lua=s" =>	\$OutputLUA
);

print << 'EOF';
#!/bin/sh
#
# Do not edit!
# This file was generated from configure.in by BSDBuild %VERSION%.
#
# To regenerate this file, get the latest BSDBuild release from
# http://hypertriton.com/bsdbuild/, and use the command:
#
#     $ cat configure.in | mkconfigure > configure
#
EOF

open($LUA, ">$OutputLUA");
print { $LUA } << 'EOF';
-- Public domain
--
-- Do not edit!
-- This file was generated from configure.in by BSDBuild %VERSION%.
--
-- To regenerate this file, get the latest BSDBuild release from
-- http://bsdbuild.hypertriton.com/, and use the command:
--
--    $ cat configure.in | mkconfigure > configure
--
hdefs = {}
mdefs = {}
EOF

#
# Initialize and parse for command-line options.
#
print << 'EOF';
# Copyright (c) 2001-2012 Hypertriton, Inc. <http://hypertriton.com/>
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
#
PACKAGE="Untitled"
VERSION=""
RELEASE=""

optarg=
for arg
do
	case "$arg" in
	-*=*)
	    optarg=`echo "$arg" | sed 's/[-_a-zA-Z0-9]*=//'`
	    ;;
	*)
	    optarg=
	    ;;
	esac

	case "$arg" in
	--build=*)
	    build_arg=$optarg
	    ;;
	--host=*)
	    host_arg=$optarg
	    ;;
	--target=*)
	    target=$optarg
	    ;;
	--emul-os=*)
	    PROJ_TARGET=$optarg
	    ;;
	--byte-order=*)
	    byte_order=$optarg
	    ;;
	--prefix=*)
	    prefix=$optarg
	    ;;
	--exec-prefix=*)
	    exec_prefix=$optarg
	    ;;
	--sysconfdir=*)
	    sysconfdir=$optarg
	    ;;
	--bindir=*)
	    bindir=$optarg
	    ;;
	--libdir=*)
	    libdir=$optarg
	    ;;
	--moduledir=*)
	    moduledir=$optarg
	    ;;
	--libexecdir=*)
	    libexecdir=$optarg
	    ;;
	--datadir=*)
	    datadir=$optarg
	    ;;
	--statedir=* | --localstatedir=*)
	    statedir=$optarg
	    ;;
	--localedir=*)
	    localedir=$optarg
	    ;;
	--mandir=*)
	    mandir=$optarg
	    ;;
	--infodir=* | --datarootdir=* | --docdir=* | --htmldir=* | --dvidir=* | --pdfdir=* | --psdir=* | --sharedstatedir=* | --sbindir=*)
	    ;;
	--enable-*)
	    option=`echo $arg | sed -e 's/--enable-//' -e 's/=.*//'`
	    option=`echo $option | sed 's/-/_/g'`
	    case "$arg" in
	        *=*)
	            eval "enable_${option}='$optarg'"
	            eval "prefix_${option}='$optarg'"
		    ;;
		*)
	            eval "enable_${option}=yes"
		    ;;
	    esac
	    ;;
	--disable-*)
	    option=`echo $arg | sed -e 's/--disable-//'`;
	    option=`echo $option | sed 's/-/_/g'`
	    eval "enable_${option}=no"
	    ;;
	--with-*)
	    option=`echo $arg | sed -e 's/--with-//' -e 's/=.*//'`
	    option=`echo $option | sed 's/-/_/g'`
	    case "$arg" in
	        *=*)
	            eval "with_${option}='$optarg'"
	            eval "prefix_${option}='$optarg'"
		    ;;
		*)
	            eval "with_${option}=yes"
		    ;;
	    esac
	    ;;
	--without-*)
	    option=`echo $arg | sed -e 's/--without-//'`;
	    option=`echo $option | sed 's/-/_/g'`
	    eval "with_${option}=no"
	    ;;
	--help)
	    show_help=yes
	    ;;
	--version)
	    show_version=yes
	    ;;
	--srcdir=*)
	    srcdir=$optarg
	    ;;
	--testdir=*)
	    testdir=$optarg
	    ;;
	--cache=*)
	    cache=$optarg
	    ;;
	--includes=*)
	    includes=$optarg
	    ;;
	--cache-file=*)
	    ;;
	--config-cache | -C)
	    ;;
	*)
	    echo "invalid argument: $arg"
	    echo "try ./configure --help"
	    exit 1
	    ;;
	esac
done
EOF

#
# See if we can use "echo -n"
#
print << 'EOF';
if [ -e "/bin/echo" ]; then
    /bin/echo -n ""
    if [ $? = 0 ]; then
    	ECHO_N="/bin/echo -n"
    else
    	ECHO_N="echo -n"
    fi
else
    ECHO_N="echo -n"
fi
EOF

#
# Check if perl is available.
#
print << 'EOF';
PERL=""
for path in `echo $PATH | sed 's/:/ /g'`; do
	if [ -x "${path}" ]; then
		if [ -e "${path}/perl" ]; then
			PERL="${path}/perl"
			break
		fi
	fi
done
EOF

#
# Check if pkgconfig is available.
#
print << 'EOF';
PKGCONFIG=""
for path in `echo $PATH | sed 's/:/ /g'`; do
	if [ -x "${path}" ]; then
		if [ -e "${path}/pkg-config" ]; then
			PKGCONFIG="${path}/pkg-config"
			break
		fi
	fi
done
EOF

#
# Sort out the installation, build and source directories. If build is
# outside of the source directory, generate the required environment in
# the working directory using mkconcurrent.pl.
#
print << 'EOF';
if [ "${prefix}" != "" ]; then
    PREFIX="$prefix"
else
    PREFIX="/usr/local"
fi
if [ "${exec_prefix}" != "" ]; then
    EXEC_PREFIX="$exec_prefix"
else
    EXEC_PREFIX="${PREFIX}"
fi
if [ "${srcdir}" != "" ]; then
	if [ "${PERL}" = "" ]; then
		echo "*"
		echo "* Separate build (--srcdir) requires perl, but there is"
		echo "* no perl interpreter to be found in your PATH."
		echo "*"
		exit 1
	fi
	SRC=${srcdir}
else
	SRC=`pwd`
fi
BLD=`pwd`
SRCDIR="${SRC}"
BLDDIR="${BLD}"

if [ "${testdir}" != "" ]; then
	echo "Configure tests will be executed in ${testdir}"
	if [ ! -e "${testdir}" ]; then
		echo "Creating ${testdir}"
		mkdir ${testdir}
	fi
else
	testdir="."
fi
EOF

#
# Check for the --includes option.
#
print << 'EOF';
if [ "${includes}" = "" ]; then
	includes="yes"
fi
case "${includes}" in
yes|no)
	;;
link)
	if [ "${with_proj_generation}" ]; then
		echo "Cannot use --includes=link with --with-proj-generation!"
		exit 1
	fi
	;;
*)
	echo "Usage: --includes [yes|no|link]"
	exit 1
	;;
esac
EOF

#
# Create empty ".depend" files, otherwise the initial "make depend" will
# fail due to "include .depend" use in <build.prog.mk>, etc. We currently
# rely on perl to do this properly (if perl is unavailable, empty .depend
# files can still be created manually).
#
print << "EOF";
if [ "\${srcdir}" = "" ]; then
	cat << EOT > configure.dep.pl
EOF
my @code = ();
open(SCRIPT, "$INSTALLDIR/gen-dotdepend.pl") || die "gen-dotdepend.pl: $!";
foreach my $s (<SCRIPT>) {
	$s =~ s/\\/\\\\/g;
	$s =~ s/\$/\\\$/g;
	print $s;
}
close(SCRIPT);
print << "EOF";
EOT
	if [ "\${PERL}" != "" ]; then
		\${PERL} configure.dep.pl .
		rm -f configure.dep.pl
	else
		echo "*"
		echo "* Warning: No perl was found. Perl is required for automatic"
		echo "* generation of .depend files. You may need to create empty"
		echo "* .depend files where it is required."
		echo "*"
	fi
fi
EOF

#
# Now process the configure.in directives.
#
my %done = ();
my $registers = 1;
my @INPUT = ();

chop(@INPUT = <STDIN>);

#
# First pass: scan for directives that will not be processed in order.
#
if ($Verbose) {
	print STDERR "First pass\n";
}
foreach $_ (@INPUT) {
	if (/^\s*#/) {
	    next;
	}
	DIRECTIVE: foreach my $s (split(';')) {
		if ($s !~ /([A-Z_]+)\((.*)\)/) {
			next DIRECTIVE;
		}
		my $cmd = uc($1);
		my $argspec = $2;
		my @args = ();
		foreach my $arg (split(',', $argspec)) {
			$arg =~ s/^\s+//;
			$arg =~ s/\s+$//;
			push @args, $arg;
		}
		if ($cmd eq 'REGISTER') {
			pass1_register(@args);
		} elsif ($cmd eq 'REGISTER_SECTION') {
			pass1_register_section(@args);
		} elsif ($cmd eq 'CONFIG_GUESS') {
			pass1_config_guess(@args);
		} elsif ($cmd eq 'C_INCDIR_CONFIG') {
			pass1_c_incdir_config(@args);
		} elsif ($cmd eq 'C_INCLUDE_CONFIG') {
			pass1_c_include_config(@args);
		}
	}
}

#
# Honor --help and --version.
#
MkIf '"${show_help}" = "yes"';
	Help();
MkEndif;
MkIf '"${show_version}" = "yes"';
	print 'echo "BSDBuild %VERSION%"',"\n";
	print 'exit 0',"\n";
MkEndif;

#
# Figure out build and host platform.
#
print << "EOF";
if [ "\${srcdir}" != "" ]; then
	build_guessed=`sh \${srcdir}/$ConfigGuess`
else
	build_guessed=`sh $ConfigGuess`
fi
if [ \$? != 0 ]; then
	echo "$ConfigGuess failed"
	exit 1
fi
if [ "\${build_arg}" != "" ]; then
	build="\${build_arg}"
else
	build="\${build_guessed}"
fi
if [ "\${host_arg}" != "" ]; then
	host="\${host_arg}"
else
	host="\${build}"
fi
if [ "\${host}" != "\${build_guessed}" ]; then
	CROSS_COMPILING="yes"
else
	CROSS_COMPILING="no"
fi
EOF

#
# Output common code
#
print << 'EOF';
echo "BSDBuild %VERSION% (host: $host)"

if [ -e "Makefile.config" ]; then
	echo "* Overwriting existing Makefile.config"
fi
echo "# Generated by configure script (BSDBuild %VERSION%)." > Makefile.config
echo "" >> Makefile.config
echo "BUILD=${build}" >> Makefile.config
echo "HOST=${host}" >> Makefile.config
echo "CROSS_COMPILING=${CROSS_COMPILING}" >> Makefile.config
echo "SRCDIR=${SRC}" >> Makefile.config
echo "BLDDIR=${BLD}" >> Makefile.config

echo "Generated by configure script" > config.log
echo "BSDBuild Version: %VERSION%" >> config.log
echo "Host: $host" >> config.log

for arg
do
	echo "Argument: $arg" >> config.log
done
EOF

if ($OutputHeaderFile) {
	print << "EOF";
if [ -e "$OutputHeaderFile" ]; then
	echo "* Overwriting $OutputHeaderFile file"
fi
echo "/* Generated by configure script (BSDBuild %VERSION%). */" > $OutputHeaderFile
EOF
}
if ($OutputHeaderDir) {
	print << "EOF";
if [ -e "$OutputHeaderDir" ]; then
	echo "* Overwriting $OutputHeaderDir directory"
	rm -fR "$OutputHeaderDir"
fi
mkdir -p "$OutputHeaderDir"
if [ \$? != 0 ]; then
	echo "Could not create $OutputHeaderDir directory."
	exit 1
fi
EOF
}

# Process standard built-in options.
BuiltinDoc();
BuiltinNLS();
BuiltinCtags();
BuiltinLibtool();

# An "env PREFIX=foo make install" should override ./configure --prefix.
print << 'EOF';
echo "PREFIX?=${PREFIX}" >> Makefile.config
EOF

MkSaveDefine('PREFIX');

#
# Define and save the conventional installation paths.
# 
my @defPaths = (
	'bindir:${PREFIX}/bin',
	'libdir:${PREFIX}/lib',
	'moduledir:${PREFIX}/lib',
	'libexecdir:${PREFIX}/libexec',
	'datadir:${PREFIX}/share',
	'statedir:${PREFIX}/var',
	'sysconfdir:${PREFIX}/etc',
	'localedir:${DATADIR}/locale',
	'mandir:${PREFIX}/man'
);
foreach my $pathSpec (@defPaths) {
	my ($path, $defPath) = split(':', $pathSpec);
	my $ucPath = uc($path);

	print << "EOF";
if [ "\${$path}" != "" ]; then
	$ucPath="\${$path}"
	${ucPath}_SPECIFIED="yes"
else
	$ucPath="$defPath"
fi
EOF
	MkSaveDefine($ucPath);
	MkSaveMK($ucPath);
}

#
# Second pass: actually process the script.
#
if ($Verbose) {
	print STDERR "Processing script\n";
}
foreach $_ (@INPUT) {
	if (/^\s*#/) {
	    next;
	}
	s/\;\;/\\{caseclose}/g;
	DIRECTIVE: foreach my $s (split(';')) {
		if ($s !~ /([A-Z_]+)\((.*)\)/) {
			$s =~ s/\\{caseclose\}/;;/g;
			print $s, "\n";
			next DIRECTIVE;
		}
		my $cmd = lc($1);
		my $argspec = $2;
		my @args = ();
		foreach my $arg (split(',', $argspec)) {
			$arg =~ s/^\s+//;
			$arg =~ s/\s+$//;
			push @args, $arg;
		}
		if (!exists($Fns{$cmd})) {
			print $s, "\n";
			next DIRECTIVE;
		}
		&{$Fns{$cmd}}(@args);
	}
}

MkSaveMK_Commit();

print << 'EOF';
if [ "${srcdir}" != "" ]; then
	$ECHO_N "* Source is in ${srcdir}. Generating Makefiles..."
	${PERL} ${SRC}/mk/mkconcurrent.pl ${SRC}
	if [ $? != 0 ]; then
		exit 1;
	fi
	echo "done"
fi
echo "*"
echo "* Configuration successful. Use \"make depend all\" to compile,"
echo "* and \"make install\" to install this software under $PREFIX."
echo "*"
EOF
