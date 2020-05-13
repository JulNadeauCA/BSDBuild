#!%PERL% -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2001-2020 Julien Nadeau Carriere <vedge@csoft.net>
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
	'register_env_var'	=> \&register_env_var,
	'register_section'	=> \&register_section,
	'test'			=> \&test,
	'check'			=> \&test,
	'require'		=> \&test_require,
	'test_dir'		=> \&test_dir,
	'disable'		=> \&disable,
	'mdefine'		=> \&mdefine,
	'mappend'		=> \&mappend,
	'hdefine'		=> \&hdefine,
	'hdefine_unquoted'	=> \&hdefine_unquoted,
	'hundef'		=> \&hundef,
	'hdefine_if'		=> \&hdefine_if,
	'hundef_if'		=> \&hundef_if,
	'ada_option'		=> \&ada_option,
	'ada_bflag'		=> \&ada_bflag,
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
	'config_cache'		=> \&config_cache,
	'config_script'		=> \&config_script,
	'pkgconfig_module'	=> \&pkgconfig_module,
	'pkgconfig_mod'		=> \&pkgconfig_module,
	'config_guess'		=> \&config_guess,
	'success_fn'		=> \&success_fn,
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
my $SuccessFn = '';
my $ParserError = '';
my $lineNo = 1;

$SIG{__WARN__} = sub {
	print STDERR 'warning: configure.in:' . $lineNo . ': ' . @_, "\n";
};
$SIG{__DIE__} = sub {
	print STDERR 'configure.in:' . $lineNo . ': ' . shift . " (near \"$_\")\n";
	exit(1);
};

# Specify software package name
sub package
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('PACKAGE', $val);
	MkSaveMK('PACKAGE');
	MkSaveDefine('PACKAGE');
	return (0);
}

# Specify software package version
sub version
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('VERSION', $val);
	MkSaveMK('VERSION');
	MkSaveDefine('VERSION');
	return (0);
}

# Specify software package release name
sub release
{
	my ($val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine('RELEASE', $val);
	MkSaveMK('RELEASE');
	MkSaveDefine('RELEASE');
	return (0);
}

# Enable/disable support for the ./configure --cache option.
sub config_cache
{
	my ($val) = @_;

	if (lc($val) eq 'yes' || lc($val) eq 'on') {
		$Cache = 1;
	} elsif (lc($val) eq 'no' || lc($val) eq 'off') {
		$Cache = 0;
	} else {
		$ParserError = 'Syntax error: "'.$val.'" (should be yes or no)';
		return (-1);
	}
	return (0);
}

# Set function to call when configure succeeds.
sub success_fn
{
	my ($val) = @_;
	$SuccessFn = $val;
	return (0);
}

# Directives used in first pass; no-ops as script directives
sub register { }
sub register_env_var { }
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

		MkPrintSN("checking for <$hdrFile> ($hdrDef)...");
		MkCompileC $hdrDef, '', '', << "EOF";
#include <$hdrFile>
int main (int argc, char *argv[]) { return (0); }
EOF
	}
	return (0);
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

		MkPrintSN("checking for <$hdrFile>...");
		MkCompileC $hdrDef, $cflags, $libs, << "EOF";
#include <$hdrFile>
int main (int argc, char *argv[]) { return (0); }
EOF
	}
	return (0);
}

# Check for a function
sub check_func
{
	foreach my $funcList (@_) {
		$funcDef = uc($funcList);
		$funcDef =~ s/[\\\/\.]/_/g;
		$funcDef = 'HAVE_'.$funcDef;

		MkPrintSN("checking for $funcList()...");
		MkDefine('TEST_CFLAGS', '-Wall');
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
	return (0);
}

# Check for a Perl module.
sub check_perl_module
{
    	my $modname = shift;
	my $define = 'HAVE_'.uc($modname);
	$define =~ s/::/_/;

	MkPrintSN("checking for Perl module $modname...");
	if ($Cache) {
		print << "EOF";
$define='No'
MK_CACHED='No'
if [ "\${cache}" != '' ]; then
	if [ -e "\${cache}/perltest-$define" ]; then
		$define=`cat \${cache}/perltest-$define`
		MK_CACHED='Yes'
	fi
fi
if [ "\${MK_CACHED}" = "No" ]; then
	cat /dev/null | \${PERL} -M$modname 2>/dev/null
	if [ \$? != 0 ]; then
		echo ": not found, code \$?" >>config.log
		$define='no'
		echo 'no'
	else
		echo ': found' >>config.log
		$define='yes'
		echo 'yes'
	fi
fi
EOF
	} else {
		print << "EOF";
$define='No'
cat /dev/null | \${PERL} -M$modname 2>/dev/null
if [ \$? != 0 ]; then
	echo ": not found, code \$?" >>config.log
	$define='no'
	echo 'no'
else
	echo ': found' >>config.log
	$define='yes'
	echo 'yes'
fi
EOF
	}
	return (0);
}

# Check for a Perl module and fail if not found.
sub require_perl_module
{
    	my $modname = shift;
	my $define = 'HAVE_'.uc($modname);
	$define =~ s/::/_/;

	check_perl_module($modname);
	
	MkIf "\"\$\{$define\}\" != \"yes\"";
		MkPrintS('* ');
		MkPrintS("* This software requires the $modname module.");
		MkPrintS("* Get it from CPAN (http://cpan.org/).");
		MkPrintS('* ');
		MkFail('Required Perl module not found');
	MkEndif;

	return (0);
}

# Specify an alternate installation directory default.
sub default_dir
{
    	my $dir = shift;
	my $default = shift;
	
	if ($dir =~ /^"(.*)"$/) { $dir = $1; }
	if ($default =~ /^"(.*)"$/) { $default = $1; }

	MkIf "\"\$\{${dir}_SPECIFIED\}\" != 'yes'";
		MkDefine($dir, $default);
		MkSaveDefine($dir);
		MkSaveMK($dir);
	MkEndif;
	
	return (0);
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

	    MkPrintSN("checking for $funcList()...");
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
	
	return (0);
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
	return (0);
}

# Execute one of the standard BSDBuild tests.
sub test
{
	my @args = @_;
	my ($t) = shift(@args);
	my $mod = undef;
	
	if (!exists($TESTS{$t})) {
		foreach my $dir (@TestDirs) {
			my $path = $dir.'/'.$t.'.pm';
			if (-e $path) {
				$mod = $path;
				last;
			}
		}
		if (!defined($mod)) {
			$ParserError = 'No such module: '.$t;
			return (-1);
		}
		do($mod);
		if ($@) {
			$ParserError = $t.' module: '.$@;
			return (-1);
		}
	}
	if (exists($DEPS{$t})) {
		foreach my $dep (split(',', $DEPS{$t})) {
			if (!exists($done{$dep})) {
				$ParserError = $t.' depends on: '.$dep;
				return (-1);
			}
		}
	}
	my $c;
	if ($EmulOS) {
		if (exists($EMUL{$t}) && defined($EMUL{$t})) {
			if (exists($EMULDEPS{$t})) {
		 		foreach my $ed (@{$EMULDEPS{$t}}) {
					if (!exists($EmulDepsTested{$ed})) {
						test($ed);
						$EmulDepsTested{$ed} = 1;
					}
				}
			}
			$c = $EMUL{$t};
		} else {
			unless (exists($DISABLE{$t}) && defined($DISABLE{$t})) {
				$ParserError = $t.': missing EMUL/DISABLE hook';
				return (-1);
			}
			$c = $DISABLE{$t};
		}
		@args = ($EmulOS, $EmulOSRel, '');
	} else {
		$c = $TESTS{$t};
	}
	if ($c) {
		MkPrintSN("checking for $DESCR{$t}...");
		if (@args) {
			MkComment("BEGIN $t(@args)");
		} else {
			MkComment("BEGIN $t");
		}
		&$c(@args);
		MkComment("END $t");
		if ($EmulOS) {
			MkPrintSN("ok\n");
		}
	} else {
		MkFail("$t: not in TESTS table");
	}
	$done{$t} = 1;
	return (0);
}

# Execute one of the standard BSDBuild tests, abort if the test fails.
sub test_require
{
	my ($t, $ver) = @_;
	my $def = 'HAVE_'.uc($t);
	$def =~ tr/-./_/;

	test(@_);
	
	if ($EmulOS) {
		return (0);
	}

	MkIf "\"\$\{$def\}\" != \"yes\"";
		MkPrintS('* ');
		if ($ver) {
			MkPrint('* $PACKAGE requires ' . $DESCR{$t} .
			         " (version $ver or newer).");
		} else {
			MkPrintS('* This software requires ' . $DESCR{$t});
		}
		if (exists($URL{$t}) && defined($URL{$t})) {
			MkPrintS("* WWW: $URL{$t}");
		}
		MkPrintS('* ');
		MkFail("Required dependency $t not found");
	MkEndif;

	if ($ver) {
		MkIfNE('${MK_VERSION_OK}', 'yes');
			MkPrintS('* ');
			MkPrintS("* This software requires $t version >= $ver,");
			MkPrintS("* please update that package and try again.");
			if (exists($URL{$t}) && defined($URL{$t})) {
				MkPrintS("* WWW: $URL{$t}");
			}
			MkPrintS('* ');
			MkFail("Required dependency $t version mismatch");
		MkEndif;
	}
	return (0);
}

# Call the "disable" function to short-circuit a test module. It should
# emulate the results of a failed test without actually running any tests.
sub disable
{
	my ($t) = @_;
	my $mod = undef;
	
	if (!exists($TESTS{$t})) {
		foreach my $dir (@TestDirs) {
			my $path = $dir.'/'.$t.'.pm';
			if (-e $path) {
				$mod = $path;
				last;
			}
		}
		if (!defined($mod)) {
			$ParserError = 'No such module: '.$t;
			return (-1);
		}
		do($mod);
		if ($@) {
			$ParserError = $t.' module: '.$@;
			return (-1);
		}
	}
	my $c = $DISABLE{$t};
	if ($c) {
		MkPrintS("not enabling $DESCR{$t}");
		&$c(1);
	}
	return (0);
}

# Make environment define
sub mdefine
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveMK($def);
	return (0);
}

# Append to make environment define
sub mappend
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, "\${$def} $val");
	MkSaveMK($def);
	return (0);
}

# Header define
sub hdefine
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.*)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefine($def);
	return (0);
}

# Header define unquoted
sub hdefine_unquoted
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefineUnquoted($def);
	return (0);
}

# Conditional header define
sub hdefine_if
{
	my ($cond, $def) = @_;

	MkIf($cond);
		MkDefine($def, "yes");
		MkSaveDefine($def);
	MkElse;
		MkSaveUndef($def);
	MkEndif;
	return (0);
}

# Header undef
sub hundef
{
	MkSaveUndef(@_);
	return (0);
}

# Conditional header undef
sub hundef_if
{
	my ($cond, $def) = @_;

	MkIf($cond);
		MkSaveUndef($def);
	MkEndif;
	return (0);
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
	return (0);
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
	return (0);
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
	\$ECHO_N "linking header files..."
	if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
		(cd \${SRCDIR} && \${PERL} mk/gen-includelinks.pl "\${SRCDIR}" "$dir" 1>>\${BLDDIR}/config.log 2>&1)
	else
		\${PERL} mk/gen-includelinks.pl "\${SRCDIR}" "$dir" 1>>config.log 2>&1
	fi
	if [ \$? != 0 ]; then
		echo "\${PERL} mk/gen-includelinks.pl failed"
		exit 1
	fi
	echo 'done'
else
	if [ "\${PERL}" = '' ]; then
		echo '*'
		echo '* The --includes=yes option requires perl, but no perl'
		echo '* interpreter was found. If perl is unavailable, please'
		echo '* please rerun configure with --includes=link'
		echo '*'
		exit 1
	fi
	\$ECHO_N "preprocessing header files..."
	if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
		(cd \${SRCDIR} && \${PERL} mk/gen-includes.pl "$dir" 1>>\${BLDDIR}/config.log 2>&1)
	else
		\${PERL} mk/gen-includes.pl "$dir" 1>>config.log 2>&1
	fi
	if [ \$? != 0 ]; then
		echo "\${PERL} mk/gen-includes.pl failed"
		exit 1
	fi
	echo 'done'
fi
EOF
	return (0);
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
	return (0);
}

# Extra compiler warnings
sub c_extra_warnings
{
	print {$LUA} 'table.insert(package.buildflags,{"extra-warnings"})'."\n";
	return (0);
}

# Fatal warnings
sub c_fatal_warnings
{
	print {$LUA} 'table.insert(package.buildflags,{"extra-warnings"})'."\n";
	return (0);
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
	return (0);
}

# Ada compiler option
sub ada_option
{
	my $opt = shift;

	MkDefine('ADAFLAGS', '$ADAFLAGS '.$opt);
	MkSaveMK('ADAFLAGS');
	return (0);
}

# Ada binder option flag
sub ada_bflag
{
	my $opt = shift;

	MkDefine('ADABFLAGS', '$ADABFLAGS '.$opt);
	MkSaveMK('ADABFLAGS');
	return (0);
}

# C compiler option
sub c_option
{
	my $opt = shift;

	MkDefine('CFLAGS', '$CFLAGS '.$opt);
	MkDefine('CXXFLAGS', '$CXXFLAGS '.$opt);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');
	return (0);
}

# Linker option
sub ld_option
{
	my $opt = shift;

	MkDefine('LDFLAGS', '$LDFLAGS '.$opt);
	MkSaveMK('LDFLAGS');
	return (0);
}

# Generate a "foo-config" style script.
sub config_script
{
	my ($out, $cflags, $libs) = @_;

	if ($out =~ /^"(.*)"$/) { $out = $1; }
	if ($cflags =~ /^"(.*)"$/) { $cflags = $1; }
	if ($libs =~ /^"(.*)"$/) { $libs = $1; }

	MkSetS('config_script_out', $out);
	MkSetS('config_script_cflags', $cflags);

	MkIfEQ('${HAVE_CC65}', 'yes');
		MkSetS('config_script_libs', $libs);
		MkSetS('config_libs_cc65', '');
		MkPushIFS('" "');
		MkFor('lib', '$config_script_libs');
			MkCaseIn('$lib');
			MkCaseBegin('-l*');
				MkSet('lib_bare',
				    '`echo "$lib" |sed "s/^-l//"`');
				MkAppend('config_libs_cc65',
				    '${prefix}/lib/${lib_bare}.lib');
				MkCaseEnd;
			MkEsac;
		MkDone;
		MkPopIFS();
		MkDefine('config_script_libs', '$config_libs_cc65');
	MkElse;
		MkDefine('config_script_libs', $libs);
	MkEndif;

	print << 'EOF';
cat << EOT > $config_script_out
#!/bin/sh
# Generated by ${PACKAGE}'s BSDBuild configure script.
#
# BSDBuild %VERSION% (https://bsdbuild.hypertriton.com/)
# ${PACKAGE} ${VERSION}

prefix='${PREFIX}'
exec_prefix='${EXEC_PREFIX}'
exec_prefix_set='no'
libdir='${LIBDIR}'

usage='\
Usage: $config_script_out [--prefix[=DIR]] [--exec-prefix[=DIR]] [--host] [--version] [--release] [--cflags] [--libs]'

if test \$# -eq 0; then
	echo "\${usage}" 1>&2
	exit 1
fi

while test \$# -gt 0; do
	case "\$1" in
	-*=*)
		optarg=\`echo "\$1" | LC_ALL='C' sed 's/[-_a-zA-Z0-9]*=//'\`
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
	--host)
		echo '${host}'
		;;
	--version)
		echo '${VERSION}'
		;;
	--release)
		echo '${RELEASE}'
		;;
	--cflags)
		echo '$config_script_cflags'
		;;
	--libs | --static-libs)
		echo '$config_script_libs'
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
	MkDefine('AVAIL_CONFIGSCRIPTS', '$AVAIL_CONFIGSCRIPTS '.$out);
	MkSaveMK('AVAIL_CONFIGSCRIPTS');
	return (0);
}

# Generate a pkg-config module
sub pkgconfig_module
{
	my ($out, $desc, $requires, $conflicts, $cflags, $libs, $libsPvt) = @_;

	if ($out =~ /^"(.*)"$/) { $out = $1; }
	if ($desc =~ /^"(.*)"$/) { $desc = $1; }
	if ($requires =~ /^"(.*)"$/) { $requires = $1; }
	if ($conflicts =~ /^"(.*)"$/) { $conflicts = $1; }
	if ($cflags =~ /^"(.*)"$/) { $cflags = $1; }
	if ($libs =~ /^"(.*)"$/) { $libs = $1; }
	if ($libsPvt =~ /^"(.*)"$/) { $libsPvt = $1; }
	print "pkgconfig_module_out=\"$out\"\n";
	print "pkgconfig_module_desc=\"$desc\"\n";
	print "pkgconfig_module_requires=\"$requires\"\n";
	print "pkgconfig_module_conflicts=\"$conflicts\"\n";
	print "pkgconfig_module_cflags=\"$cflags\"\n";
	print "pkgconfig_module_libs=\"$libs\"\n";
	print "pkgconfig_module_libs_pvt=\"$libsPvt\"\n";
	print << 'EOF';
cat << EOT > $pkgconfig_module_out.pc
# ${PACKAGE} pkg-config source file.
#
# Generated by ${PACKAGE}'s BSDBuild-based configure script.
# BSDBuild %VERSION% (https://bsdbuild.hypertriton.com/).

prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: $pkgconfig_module_out
Description: $pkgconfig_module_desc
Version: ${VERSION}
Requires: $pkgconfig_module_requires
Conflicts: $pkgconfig_module_conflicts
Libs: $pkgconfig_module_libs
Libs.private: $pkgconfig_module_libs_pvt
Cflags: $pkgconfig_module_cflags
EOT
EOF
	MkDefine('AVAIL_PCMODULES', '$AVAIL_PCMODULES '.$out.'.pc');
	MkSaveMK('AVAIL_PCMODULES');
	return (0);
}

#
# End macros
#

#
# Procedures handled by first pass.
#
sub P1_register
{
	my ($arg, $descr) = @_;

	if ($arg =~ /\"(.*)\"/) { $arg = $1; }
	if ($descr =~ /\"(.*)\"/) { $descr = $1; }

	my $darg = pack('A' x 27, split('', $arg));
	push @Help, "echo '    $darg $descr'";
	return (0);
}
sub P1_register_section
{
	my ($s) = @_;

	if ($s =~ /\"(.*)\"/) { $s = $1; }
	push @Help, "echo ''";
	push @Help, "echo '$s'";
	return (0);
}
sub P1_register_env_var
{
	RegisterEnvVar(@_);
	return (0);
}
sub P1_config_guess
{
	my ($s) = @_;

	if ($s =~ /\"(.*)\"/) { $s = $1; }
	if ($Verbose) {
		print STDERR "Using config.guess: $s\n";
	}
	$ConfigGuess = $s;
	return (0);
}
sub P1_c_incdir_config
{
	my $dir = shift;

	if ($dir) {
		$OutputHeaderDir = $dir;
		MkSetS('bb_incdir', $dir);
	} else {
		$OutputHeaderDir = undef;
	}
	return (0);
}
sub P1_c_include_config
{
	my $file = shift;

	if ($file) {
		MkIfExists('$file');
			MkPrint('Overwriting $file');
			print 'rm -f "$file"', "\n";
			MkSetS('iconf', '$file');
		MkEndif;
		$OutputHeaderFile = $file;
	} else {
		$OutputHeaderFile = undef;
	}
	return (0);
}
sub P1_test
{
	my @args = @_;
	my ($t) = shift(@args);
	my $mod = undef;

	if (!exists($TESTS{$t})) {
		foreach my $dir (@TestDirs) {
			my $path = $dir.'/'.$t.'.pm';
			if (-e $path) {
				$mod = $path;
				last;
			}
		}
		if (!defined($mod)) {
			$ParserError = 'No such module: '.$t;
			return (-1);
		}
		do($mod);
		if ($@) {
			$ParserError = $t.' module: '.$@;
			return (-1);
		}
	}
	return (0);
}

sub Help
{
	my %stdOpts = (
		'--srcdir=p' =>		'Source directory for concurrent build',
		'--build=s' =>		'Host environment for build',
		'--host=s' =>		'Cross-compile for target environment',
		'--byte-order=s' =>	'Byte order for build [LE|BE]',
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
		'--includes=s' =>	'Preprocess C headers [yes|no|link]',
		'--program-prefix=s' =>	'Prepend string to program name',
		'--program-suffix=s' =>	'Append string to program name',
		'--program-transform-name=s' =>	'Transform program name by expression',
		'--keep-conftest' =>	'Preserve output files from last test',
		
		'--enable-nls' =>	'Multi-language support',
		'--with-gettext' =>	'Use gettext for multi-language',
		'--with-libtool=s' =>	'Use GNU libtool [path or "bundled"]',
		'--with-manpages' =>	'Generate manual pages',
		'--with-manlinks' =>	'Manual page entries for all functions',
		'--with-ctags' =>	'Generate ctags tag files',
		'--with-docs' =>	'Generate printable documentation',
		'--with-bundles' =>	'Generate application/library bundles',
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
		'--includes=s' =>	'yes',
		'--program-prefix=s' =>	'',
		'--program-suffix=s' =>	'',
		'--program-transform-name=s' =>	's,x,x,',

		'--enable-nls' =>	'no',
		'--with-gettext' =>	'auto-detect',
		'--with-libtool' =>	'bundled',
		'--with-manpages' =>	'yes',
		'--with-manlinks' =>	'no',
		'--with-ctags' =>	'no',
		'--with-docs' =>	'no',
		'--with-bundles' =>	'yes',
	);
   
	if ($Cache) {
		$stdOpts{'--cache=p'} = 'Cache test results in directory';
		$stdDefaults{'--cache=p'} = 'none';
	}

	print << 'EOF';
echo ''
echo 'Usage: ./configure [options]'
echo ''
echo 'Standard build options:'
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
		my $optFmt = pack('A' x 26, split('', $optName));
		print 'echo \'    '.$optFmt.' '.$stdOpts{$opt};
		if (exists($stdDefaults{$opt})) {
			print ' ['.$stdDefaults{$opt}.']';
		}
		print "'\n";
	}
	print join("\n",@Help),"\n";
	print << 'EOF';
echo ''
echo 'Some influential environment variables:'
EOF
	foreach my $v (sort keys %HELPENV) {
		print $HELPENV{$v} . "\n";
	}
	print "exit 1\n";
	return (0);
}

sub Version
{
	print << "EOF";
if [ "${PACKAGE}" != '' ]; then
	echo "BSDBuild %VERSION%, for ${PACKAGE} ${VERSION}"
else
	echo 'BSDBuild %VERSION%'
fi
exit 1
EOF
	return (0);
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
# 
# This file was generated from configure.in. To regenerate it properly, get
# BSDBuild %VERSION% or later from https://bsdbuild.hypertriton.com/ and use:
#
#     $ mkconfigure < configure.in > configure
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
-- https://bsdbuild.hypertriton.com/, and use the command:
--
--    $ mkconfigure < configure.in > configure
--
hdefs = {}
mdefs = {}
EOF

#
# Initialize and parse for command-line options.
#
print << 'EOF';
echo 'BSDBuild %VERSION% <https://bsdbuild.hypertriton.com/>'
echo '# BSDBuild %VERSION% <https://bsdbuild.hypertriton.com/>' > config.log
echo '# ex:syn=sh' >> config.log
echo '#!/bin/sh' >config.status
echo >>config.status

PACKAGE='Untitled'
VERSION=
RELEASE=
PROG_PREFIX=
PROG_SUFFIX=
PROG_TRANSFORM=s,x,x,

case "test" in
*)
	bb_sed_test=`echo foo-.bar |sed 's/[-.]/_/g'`
	if [ "$bb_sed_test" != "foo__bar" ]; then
		echo "sed or $SHELL is not working correctly."
		exit 1
	fi
esac


bb_cr_letters='abcdefghijklmnopqrstuvwxyz'
bb_cr_LETTERS='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
bb_cr_Letters=$bb_cr_letters$bb_cr_LETTERS
bb_cr_digits='0123456789'
bb_cr_alnum=$bb_cr_Letters$bb_cr_digits
optarg=
for arg
do
	case "$arg" in
	*=*)
	    optarg=`expr "X$arg" : '[^=]*=\(.*\)'`
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
	    option=`expr "x$arg" : 'x-*enable-\([^=]*\)'`
	    expr "x$option" : ".*[^-._$bb_cr_alnum]" >/dev/null &&
	        { echo "Invalid option name: $option" >&2
	        { (exit 1); exit 1; }; }
	    option=`echo $option | sed 's/[-.]/_/g'`
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
	    option=`expr "x$arg" : 'x-*disable-\([^=]*\)'`
	    expr "x$option" : ".*[^-._$bb_cr_alnum]" >/dev/null &&
	        { echo "Invalid option name: $option" >&2
	        { (exit 1); exit 1; }; }
	    option=`echo $option | sed 's/[-.]/_/g'`
	    eval "enable_${option}=no"
	    ;;
	--with-*)
    	    option=`expr "x$arg" : 'x-*with-\([^=]*\)'`
	    expr "x$option" : ".*[^-._$bb_cr_alnum]" >/dev/null &&
	        { echo "Invalid option name: $option" >&2
	        { (exit 1); exit 1; }; }
    	    option=`echo $option | sed 's/[-.]/_/g'`
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
    	    option=`expr "x$arg" : 'x-*without-\([^=]*\)'`
	    expr "x$option" : ".*[^-._$bb_cr_alnum]" >/dev/null &&
	        { echo "Invalid option name: $option" >&2
	        { (exit 1); exit 1; }; }
	    option=`echo $option | sed 's/-/_/g'`
	    eval "with_${option}=no"
	    ;;
	--x-includes=*)
	    with_x_includes=$optarg
	    ;;
	--x-libraries=*)
	    with_x_libraries=$optarg
	    ;;
	--program-prefix=*)
	    PROG_PREFIX=$optarg
	    ;;
	--program-suffix=*)
	    PROG_SUFFIX=$optarg
	    ;;
	--program-transform-name=*)
	    PROG_TRANSFORM=$optarg
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
	--keep-conftest)
	    keep_conftest=yes
	    ;;
	--cache-file=*)
	    ;;
	--config-cache | -C)
	    ;;
	*)
	    echo "Invalid argument: $arg, see ./configure --help"
	    exit 1
	    ;;
	esac
done
EOF

print << 'EOF';
if [ -e "/bin/echo" ]; then
    /bin/echo -n ""
    if [ $? = 0 ]; then
    	ECHO_N='/bin/echo -n'
    else
    	ECHO_N='echo -n'
    fi
else
    ECHO_N='echo -n'
fi

if [ "${PATH_SEPARATOR+set}" != set ]; then
	echo '#!/bin/sh' > conftest$$.sh
	echo 'exit 0' >> conftest$$.sh
	chmod +x conftest$$.sh
	if (PATH="/nonexistent;."; conftest$$.sh) >/dev/null 2>&1; then
		PATH_SEPARATOR=';'
	else
		PATH_SEPARATOR=:
	fi
	rm -f conftest$$.sh
fi

bb_save_IFS=$IFS
IFS=$PATH_SEPARATOR

SH='sh'
for path in $PATH; do
	if [ -x "${path}/sh" ]; then
		SH="${path}/sh"
		break
	elif [ -e "${path}/sh.exe" ]; then
		SH="${path}/sh.exe"
		break
	fi
done

PERL=''
for path in $PATH; do
	if [ -x "${path}/perl" ]; then
		PERL="${path}/perl"
		break
	elif [ -e "${path}/perl.exe" ]; then
		PERL="${path}/perl.exe"
		break
	fi
done

PKGCONFIG=''
for path in $PATH; do
	if [ -x "${path}/pkg-config" ]; then
		PKGCONFIG="${path}/pkg-config"
		break
	elif [ -e "${path}/pkg-config.exe" ]; then
		PKGCONFIG="${path}/pkg-config.exe"
		break
	fi
done
IFS=$bb_save_IFS
EOF

MkSaveMK('PATH_SEPARATOR', 'PROG_PREFIX', 'PROG_SUFFIX', 'PROG_TRANSFORM');

#
# Sort out the installation, build and source directories. If build is
# outside of the source directory, generate the required environment in
# the working directory using mkconcurrent.pl.
#
print << 'EOF';
if [ "${prefix}" != '' ]; then
    PREFIX="$prefix"
else
    PREFIX='/usr/local'
fi
if [ "${exec_prefix}" != '' ]; then
    EXEC_PREFIX="$exec_prefix"
else
    EXEC_PREFIX="${PREFIX}"
fi
if [ "${srcdir}" != '' ]; then
	if [ "${PERL}" = '' ]; then
		echo '*'
		echo '* Separate build --srcdir requires perl, but there is'
		echo '* no perl interpreter to be found in your PATH.'
		echo '*'
		exit 1
	fi
	SRC=${srcdir}
else
	SRC=`pwd`
fi
BLD=`pwd`
SRCDIR="${SRC}"
BLDDIR="${BLD}"

if [ "${testdir}" != '' ]; then
	echo "Configure tests will be executed in ${testdir}"
	if [ ! -e "${testdir}" ]; then
		echo "Creating ${testdir}"
		mkdir ${testdir}
	fi
else
	testdir='.'
fi
EOF

#
# Check for the --includes option.
#
print << 'EOF';
if [ "${includes}" = '' ]; then
	includes='yes'
fi
case "${includes}" in
yes|no)
	;;
link)
	if [ "${with_proj_generation}" ]; then
		echo 'Cannot use --includes=link with --with-proj-generation'
		exit 1
	fi
	;;
*)
	echo 'Usage: --includes (yes|no|link)'
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
if [ "\${srcdir}" = '' ]; then
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
	if [ "\${PERL}" != '' ]; then
		\${PERL} configure.dep.pl .
		rm -f configure.dep.pl
	else
		echo '*'
		echo '* Warning: No perl was found. Perl is required for automatic'
		echo '* generation of .depend files. You may need to create empty'
		echo '* .depend files where it is required.'
		echo '*'
	fi
fi
EOF

#
# Now process the configure.in directives.
#
my %done = ();
my $registers = 1;
my @INPUT = ();
my %INPUT_LINENO = ();

#
# Read input, processing long line breaks.
#
my $trunc = 0;
my $truncLine = '';
my $inLineNo = 1;
while (<STDIN>) {
	chop;
	if ($trunc) {
		$truncLine .= ' '.$_;
		if (!/\\$/) {
			$truncLine =~ s/\s+/ /g;
			push @INPUT, $truncLine;
			$INPUT_LINENO{$inLineNo}=$lineNo; $inLineNo++;
			$truncLine = '';
			$trunc = 0;
		} else {
			chop($truncLine);
		}
	} else {
		if (/\\$/) {
			chop;
			$truncLine = $_;
			$truncLine =~ s/\s+/ /g;
			$trunc = 1;
		} else {
			push @INPUT, $_;
			$INPUT_LINENO{$inLineNo}=$lineNo; $inLineNo++;
		}
	}
	$lineNo++;
}

#
# First pass: scan for special directives which will not be processed
# directly into Bourne script fragments.
#
if ($Verbose) {
	print STDERR "First pass\n";
}
$lineNo = 1;
LINE: foreach $_ (@INPUT) {
	if (/^\s*#/) {
		$lineNo++;
		next LINE;
	}

	my $line_in = '';
	my $inQuotes = 0;
	foreach my $char (split('', $_)) {
		if ($char eq '"') {
			if ($inQuotes) {
				$inQuotes = 0;
			} else {
				$inQuotes = 1;
			}
		}
		if ($char eq ';' && $inQuotes) {
			$line_in .= 'BSDBuild_escapethissemicolon';
		} else {
			$line_in .= $char;
		}
	}

	DIRECTIVE: foreach my $s (split(';', $line_in)) {
		if ($s !~ /([A-Za-z_]+)\((.*)\)/) {
			next DIRECTIVE;
		}
		my $cmd = lc($1);
		my $argspec = $2;
		my @args = ();
		if (!exists($Fns{$cmd})) {
			next DIRECTIVE;
		}
		my $newSpec = '';
		my $inQuotes = 0;
		foreach my $char (split('', $argspec)) {
			if ($char eq '"') {
				if ($inQuotes) {
					$inQuotes = 0;
				} else {
					$inQuotes = 1;
				}
			}
			if ($char eq ',' && $inQuotes) {
				$newSpec .= 'BSDBuild_escapethiscomma';
			} else {
				$newSpec .= $char;
			}
		}
		foreach my $arg (split(',', $newSpec)) {
			$arg =~ s/BSDBuild_escapethiscomma/,/g;
			$arg =~ s/BSDBuild_escapethissemicolon/;/g;
			$arg =~ s/^\s+//;
			$arg =~ s/\s+$//;
			push @args, $arg;
		}
		if ($cmd eq 'register') {
			P1_register(@args);
		} elsif ($cmd eq 'register_env_var') {
			P1_register_env_var(@args);
		} elsif ($cmd eq 'register_section') {
			P1_register_section(@args);
		} elsif ($cmd eq 'config_guess') {
			P1_config_guess(@args);
		} elsif ($cmd eq 'c_incdir_config') {
			P1_c_incdir_config(@args);
		} elsif ($cmd eq 'c_include_config') {
			P1_c_include_config(@args);
		} elsif ($cmd eq 'require' || $cmd eq 'check') {
			if (P1_test(@args) == -1) {
				print STDERR 'configure.in:' . $INPUT_LINENO{$lineNo} .
				             ': ' . $ParserError . "\n";
				exit(1);
			}
		}
	}
	$lineNo++;
}

#
# Honor --help and --version.
#
MkIf '"${show_help}" = "yes"';
	Help();
MkEndif;
MkIf '"${show_version}" = "yes"';
	print 'echo \'BSDBuild %VERSION%\'', "\n";
	print 'exit 0', "\n";
MkEndif;

#
# Figure out build and host platform.
#
print << "EOF";
if [ "\${build_arg}" != '' ]; then
	build="\${build_arg}"
else
	if [ "\${srcdir}" != '' ]; then
		build_guessed=`sh \${srcdir}/$ConfigGuess`
	else
		build_guessed=`sh $ConfigGuess`
	fi
	if [ \$? != 0 ]; then
		echo '$ConfigGuess failed, please specify --build'
		exit 1
	fi
	build="\${build_guessed}"
fi
if [ "\${host_arg}" != '' ]; then
	host="\${host_arg}"
else
	host="\${build}"
fi
if [ "\${host}" != "\${build}" ]; then
	CROSS_COMPILING='yes'
else
	CROSS_COMPILING='no'
fi
if [ "\${with_bundles}" != "no" ]; then
	case "\${host}" in
	arm-apple-darwin*)
		PROG_BUNDLE='iOS'
		;;
	*-*-darwin*)
		PROG_BUNDLE='OSX'
		;;
	esac
fi
host_machine=`echo \${host} | cut -d- -f 1`
EOF

MkSaveMK('PROG_BUNDLE');

print << 'EOF';
if [ -e "Makefile.config" ]; then
	echo '* Overwriting existing Makefile.config'
fi
echo '# Generated by BSDBuild %VERSION% configure script.' >Makefile.config
echo '' >> Makefile.config
echo "BUILD=${build}" >> Makefile.config
echo "HOST=${host}" >> Makefile.config
echo "CROSS_COMPILING=${CROSS_COMPILING}" >> Makefile.config
echo "SRCDIR=${SRC}" >> Makefile.config
echo "BLDDIR=${BLD}" >> Makefile.config
echo "ECHO_N=${ECHO_N}" >> Makefile.config

if [ "${SUDO}" != "" ]; then
	if [ -e "${PREFIX}" ]; then
		bb_test_file="${PREFIX}/bsdbuild_test_file$$"
		$ECHO_N "# checking the writeability of ${PREFIX}..." >>config.log
		echo "echo 'Test' > '${bb_test_file}'" > conftest$$.sh
		${SH} conftest$$.sh 2>/dev/null
		if [ -e "${bb_test_file}" ]; then
			rm -f "${bb_test_file}"
			echo "yes (ignoring SUDO)" >>config.log
			echo "SUDO=" >> Makefile.config
		else
			echo "no (honoring ${SUDO})" >>config.log
		fi
		rm -f conftest$$.sh
	fi
fi

$ECHO_N 'env ' >>config.log
$ECHO_N 'env ' >>config.status
EOF

foreach my $regEnv (sort keys %HELPENV) {
	MkIfNE('$'.$regEnv, '');
		print '$ECHO_N ' . "'" . $regEnv . "=\"' >> config.log\n";
		print '$ECHO_N ' . "'" . $regEnv . "=\"' >> config.status\n";
		print '$ECHO_N "${' . $regEnv . '}" >> config.log', "\n";
		print '$ECHO_N "${' . $regEnv . '}" >> config.status', "\n";
		print '$ECHO_N \'" \' >> config.log', "\n";
		print '$ECHO_N \'" \' >> config.status', "\n";
	MkEndif;
}

print << 'EOF';
$ECHO_N './configure' >>config.log
$ECHO_N './configure' >>config.status
for arg
do
	$ECHO_N " $arg" >>config.log
	$ECHO_N " $arg" >>config.status
done
echo '' >>config.log
echo '' >>config.status
EOF

if ($OutputHeaderFile) {
	print << "EOF";
if [ -e "$OutputHeaderFile" ]; then
	echo '* Overwriting $OutputHeaderFile file'
fi
echo '/* Generated by BSDBuild %VERSION% configure script. */' > $OutputHeaderFile
EOF
}
if ($OutputHeaderDir) {
	print << "EOF";
if [ -e "$OutputHeaderDir" ]; then
	echo '* Overwriting $OutputHeaderDir directory'
	rm -fR "$OutputHeaderDir"
fi
mkdir -p "$OutputHeaderDir"
if [ \$? != 0 ]; then
	echo 'Could not create $OutputHeaderDir directory.'
	exit 1
fi
EOF
}

# Process standard built-in options.
BuiltinDoc();
BuiltinNLS();
BuiltinCtags();
BuiltinLibtool();

# "env PREFIX=foo make install" overrides configure --prefix.
# "env LDFLAGS=foo make" overrides configure's recorded LDFLAGS.
print << 'EOF';
echo "PREFIX?=${PREFIX}" >> Makefile.config
echo "LDFLAGS?=${LDFLAGS}" >> Makefile.config

if [ "${PKGCONFIG}" != "" ]; then
	case "${host}" in
	*-*-freebsd* | *-*-dragonfly*)
		PKGCONFIG_LIBDIR="\${PREFIX}/libdata/pkgconfig"
		;;
	*)
		PKGCONFIG_LIBDIR="\${PREFIX}/lib/pkgconfig"
		;;
	esac
fi
EOF

MkSaveMK('PKGCONFIG', 'PKGCONFIG_LIBDIR');
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
if [ "\${$path}" != '' ]; then
	$ucPath="\${$path}"
	${ucPath}_SPECIFIED='yes'
else
EOF
	if ($path eq 'mandir') {
		print << "EOF";
	case "\${host}" in
	*-*-darwin*)
		$ucPath="\${PREFIX}/share/man"
		;;
	*)
		$ucPath="\${PREFIX}/man"
		;;
	esac
EOF
	} else {
		print << "EOF";
	$ucPath="$defPath"
EOF
	}
	print << 'EOF';
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
$lineNo = 1;
LINE: foreach $_ (@INPUT) {
	if (/^\s*#/) {
		$lineNo++;
		next LINE;
	}
	s/\;\;/BSDBuild__keepcaseclose/g;
	DIRECTIVE: foreach my $s (split(';')) {
		if ($s !~ /([A-Za-z_]+)\((.*)\)/) {
			$s =~ s/BSDBuild__keepcaseclose/;;/g;
			print $s, "\n";
			next DIRECTIVE;
		}
		my $cmd = lc($1);
		my $argspec = $2;
		my @args = ();
		my $inQuote = 0;
		my @argsp = ();
		foreach my $c (split('', $argspec)) {
			if ($c eq '"') {
				if ($inQuote) {
					$inQuote = 0;
				} else {
					$inQuote = 1;
				}
				push @argsp, '"';
				next;
			}
			if ($inQuote) {
				if ($c eq ',') {
					push @argsp, '_BSDBuild__COMMA_';
				} else {
					push @argsp, $c;
				}
			} else {
				push @argsp, $c;
			}
		}
		foreach my $arg (split(',', join('', @argsp))) {
			$arg =~ s/_BSDBuild__COMMA_/,/g;
			$arg =~ s/^\s+//;
			$arg =~ s/\s+$//;
			push @args, $arg;
		}
		#print STDERR "Calling $cmd(@args)\n";
		if (!exists($Fns{$cmd})) {
			print $s, "\n";
			next DIRECTIVE;
		}
		$ParserError = '';
		if (&{$Fns{$cmd}}(@args) == -1 && $ParserError ne '') {
			print STDERR 'configure.in:' . $INPUT_LINENO{$lineNo} .
			             ': ' . $ParserError . "\n";
			exit(1);
		}
	}
	$lineNo++;
}

MkSaveMK_Commit();

print << 'EOF';
if [ "${srcdir}" != '' ]; then
	$ECHO_N "preparing build environment (source in ${srcdir})..."
	${PERL} ${SRC}/mk/mkconcurrent.pl ${SRC}
	if [ $? != 0 ]; then
		exit 1;
	fi
	echo 'ok'
fi
EOF
if ($SuccessFn) {
	print $SuccessFn . "\n";
} else {
	print << "EOF";
echo '**'
echo '** Configuration successful!'
echo '**'
echo '** Use "make depend all" to compile. When finished,'
\$ECHO_N '** run "make install" to install under '
echo "\${PREFIX}."
echo '**'
EOF
}
