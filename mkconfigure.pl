#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2001-2009 Hypertriton, Inc. <http://hypertriton.com/>
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
use Getopt::Long;

my %Macros = (
	'mdefine'		=> \&mdefine,
	'hdefine'		=> \&hdefine,
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
);

# Make environment define
sub mdefine
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveMK($def);
}

# C header define
sub hdefine
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefine($def);
}

# C header undef
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
	my $subdir = shift;

	print << "EOF";
if [ ! -e "$dir" ]; then mkdir "$dir"; fi
if [ "\${includes}" = "link" ]; then
	echo "* Not preprocessing includes"
	if [ ! -e "$dir/$subdir" ]; then
		if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
			ln -s "\$SRC" "$dir/$subdir"
		else
			ln -s "\$BLD" "$dir/$subdir"
		fi
	fi
else
	if [ "\${PERL}" = "" ]; then
		echo "*"
		echo "* The --includes=yes option requires perl, but no perl"
		echo "* interpreter was found. If perl is unavailable, please"
		echo "* please rerun configure with --includes=link instead."
		echo "*"
		exit 1
	fi
	if [ ! -e "$dir/$subdir" ]; then
		if [ "\${SRCDIR}" != "\${BLDDIR}" ]; then
			\$ECHO_N "* Preprocessing includes (from \${SRCDIR})..."
			(cd \${SRCDIR} && \${PERL} mk/gen-includes.pl "\${BLDDIR}/$dir/$subdir" 1>>\${BLDDIR}/config.log 2>&1)
			echo "cp -fR config $dir/$subdir"
			cp -fR config $dir/$subdir
		else
			\$ECHO_N "* Preprocessing includes (in \${BLDDIR})...";
			\${PERL} mk/gen-includes.pl "$dir/$subdir" 1>>config.log 2>&1
		fi
		if [ \$? != 0 ]; then
			echo "\${PERL} mk/gen-includes.pl failed"
			exit 1
		fi
		echo "done"
	else
		echo "* Using existing includes"
	fi
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

# BSDBuild target ./config include directory.
sub c_incdir_config
{
	my $dir = shift;
	my @dirtoks = split('/', $dir);
	pop(@dirtoks);
	$dirparent = join('/', @dirtoks);

	print << "EOF";
if [ -e "$dirparent" ]; then
	echo "cp -fR config $dir"
	cp -fR config "$dir"
fi
EOF
}

#
# End macros
#

sub Register
{
	my ($arg, $descr) = @_;
	$arg =~ /\"(.*)\"/;
	$arg = $1;
	$descr =~ /\"(.*)\"/;
	$descr = $1;

	my $darg = pack('A' x 25, split('', $arg));
	push @HELP, "echo \"    $darg $descr\"";
}

sub Help
{
    my $prefix_opt = pack('A' x 25, split('', '--prefix'));
    my $sysconfdir_opt = pack('A' x 25, split('', '--sysconfdir'));
    my $bindir_opt = pack('A' x 25, split('', '--bindir'));
    my $libdir_opt = pack('A' x 25, split('', '--libdir'));
    my $sharedir_opt = pack('A' x 25, split('', '--sharedir'));
    my $localedir_opt = pack('A' x 25, split('', '--localedir'));
    my $mandir_opt = pack('A' x 25, split('', '--mandir'));
    my $infodir_opt = pack('A' x 25, split('', '--infodir'));
    my $srcdir_opt = pack('A' x 25, split('', '--srcdir'));
    my $testdir_opt = pack('A' x 25, split('', '--testdir'));

    my $cache_opt = pack('A' x 25, split('', '--cache'));
    my $includes_opt = pack('A' x 25, split('', '--includes'));

    my $nls_opt = pack('A' x 25, split('', '--enable-nls'));
    my $gettext_opt = pack('A' x 25, split('', '--with-gettext'));
    my $libtool_opt = pack('A' x 25, split('', '--with-libtool'));
    my $cygwin_opt = pack('A' x 25, split('', '--with-cygwin'));
    my $manpages_opt = pack('A' x 25, split('', '--with-manpages'));
    my $manlinks_opt = pack('A' x 25, split('', '--with-manlinks'));
    my $ctags_opt = pack('A' x 25, split('', '--with-ctags'));
    my $docs_opt = pack('A' x 25, split('', '--with-docs'));
    
    my $regs = join("\n",
        "echo \"    $prefix_opt Installation prefix [/usr/local]\"",
        "echo \"    $sysconfdir_opt System-wide configuration prefix [/etc]\"",
        "echo \"    $bindir_opt Executable directory [\$PREFIX/bin]\"",
        "echo \"    $libdir_opt Library directory [\$PREFIX/lib]\"",
        "echo \"    $sharedir_opt Share directory [\$PREFIX/share]\"",
        "echo \"    $localedir_opt Locale directory [\$PREFIX/share/locale]\"",
        "echo \"    $mandir_opt Manpage directory [\$PREFIX/share/man]\"",
        "echo \"    $infodir_opt Info directory [\$PREFIX/share/info]\"",
        "echo \"    $srcdir_opt Source tree for concurrent build [.]\"",
        "echo \"    $testdir_opt Directory in which to execute tests [.]\"",
        "echo \"    $cache_opt Cache directory for test results [none]\"",
        "echo \"    $manpages_opt Manual pages (-mdoc) [yes]\"",
        "echo \"    $manlinks_opt Manual pages links for functions [no]\"",
        "echo \"    $ctags_opt Automatically generate tag files [no]\"",
        "echo \"    $docs_opt Printable docs (-me/tbl/eqn/pic/refer) [no]\"",
        "echo \"    $includes_opt Preprocess headers (yes|no|link) [yes]\"",
        "echo \"    $libtool_opt Specify path to libtool [use bundled]\"",
        "echo \"    $cygwin_opt Add cygwin dependencies under cygwin [no]\"",
        "echo \"    $nls_opt Native Language Support [no]\"",
        "echo \"    $gettext_opt Use gettext tools [check]\"",
	@HELP);

    print << "EOF";
echo "Usage: ./configure [args]"
$regs
exit 1
EOF
}

sub Version
{
    print << "EOF";
echo "BSDbuild %VERSION%"
exit 1
EOF
}

#
# BEGIN
#

$INSTALLDIR = '%PREFIX%/share/bsdbuild';
	
GetOptions("emul-os=s" =>	\$EmulOS,
           "emul-osrel=s" =>	\$EmulOSRel,
           "emul-env=s" =>	\$EmulEnv,
           "output-lua=s" =>	\$OutputLUA);

print << 'EOF';
#!/bin/sh
#
# Do not edit!
# This file was generated from configure.in by BSDbuild %VERSION%.
#
# To regenerate this file, get the latest BSDbuild release from
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
-- This file was generated from configure.in by BSDbuild %VERSION%.
--
-- To regenerate this file, get the latest BSDbuild release from
-- http://hypertriton.com/bsdbuild/, and use the command:
--
--    $ cat configure.in | mkconfigure > configure
--
hdefs = {}
mdefs = {}
EOF

print << 'EOF';
# Copyright (c) 2001-2009 Hypertriton, Inc. <http://hypertriton.com/>
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
	--prefix=*)
	    prefix=$optarg
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
	--sharedir=*)
	    sharedir=$optarg
	    ;;
	--localedir=*)
	    localedir=$optarg
	    ;;
	--mandir=*)
	    mandir=$optarg
	    ;;
	--infodir=*)
	    infodir=$optarg
	    ;;
	--enable-*)
	    option=`echo $arg | sed -e 's/--enable-//' -e 's/=.*//'`
	    option=`echo $option | sed 's/-/_/g'`
	    case "$arg" in
	        *=*)
	            eval "enable_${option}='$optarg'"
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
	    help=yes
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
	*)
	    echo "invalid argument: $arg"
	    echo "try ./configure --help"
	    exit 1
	    ;;
	esac
done

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

PERL=""
for path in `echo $PATH | sed 's/:/ /g'`; do
	if [ -x "${path}" ]; then
		if [ -e "${path}/perl" ]; then
			PERL="${path}/perl"
			break
		fi
	fi
done

if [ "${prefix}" != "" ]; then
    PREFIX="$prefix"
else
    PREFIX="/usr/local"
fi

if [ "${srcdir}" != "" ]; then
	if [ "${PERL}" = "" ]; then
		echo "*"
		echo "* Separate build (--srcdir) requires perl, but there is"
		echo "* no perl interpreter to be found in your PATH."
		echo "*"
		exit 1
	fi
	echo "* Separate build (source in ${srcdir})"
	SRC=${srcdir}
	${PERL} ${SRC}/mk/mkconcurrent.pl ${SRC}
	if [ $? != 0 ]; then
		exit 1;
	fi
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
if ($EmulOS || $EmulEnv) {
	print STDERR "Emulating OS: $EmulOS\n";
	print STDERR "Emulating OS Release: \"$EmulOSRel\"\n";
	print STDERR "Emulating Environment: \"$EmulEnv\"\n";
}

my %done = ();
my $registers = 1;
while (<STDIN>) {
	chop;
	if (/^\s*#/) {
	    next;
	}
	DIRECTIVE: foreach my $s (split(';')) {
		if ($s =~ /([A-Z_]+)\((.*)\)/) {
			my $cmd = lc($1);
			my $argspec = $2;
			my @args = ();

			foreach my $arg (split(',', $argspec)) {
				$arg =~ s/^\s+//;
				$arg =~ s/\s+$//;
				push @args, $arg;
			}

			if ($cmd eq 'register') {
				Register(@args);
			} else {
				if ($registers) {
					print << 'EOF';
if [ "${help}" = "yes" ]; then
EOF
					Help();
					print << 'EOF';
fi

MACHINE=`uname -m 2>/dev/null` || MACHINE=unknown
OSRELEASE=`uname -r 2>/dev/null` || OSRELEASE=unknown
SYSTEM=`uname -s 2>/dev/null` || SYSTEM=unknown
HOST="$SYSTEM-$OSRELEASE-$MACHINE"

echo "# File generated by configure script (BSDbuild %VERSION%)." > Makefile.config
echo "# Host: ${HOST}" >> Makefile.config
echo "" >> Makefile.config
echo "SRCDIR=${SRC}" >> Makefile.config
echo "BLDDIR=${BLD}" >> Makefile.config

echo "Host: $HOST"
echo "Machine: $MACHINE" > config.log
echo "Release: $OSRELEASE" >> config.log
echo "System: $SYSTEM" >> config.log

for arg
do
	echo "Argument: $arg" >> config.log
done
if [ -e "config" ]; then
	if [ -f "config" ]; then
		echo "File ./config is in the way. Please remove it first."
		exit 1;
	else
		rm -fR config;
	fi
fi
mkdir config
if [ $? != 0 ]; then
	echo "Could not create ./config/ directory."
	exit 1
fi

# Process built-in documentation options.
HAVE_MANDOC="no"
NROFF=""
for path in `echo $PATH | sed 's/:/ /g'`; do
	if [ -x "${path}/nroff" ]; then
		NROFF="${path}/nroff"
	fi
done
if [ "${NROFF}" != "" ]; then
	echo | ${NROFF} -Tmandoc >/dev/null
	if [ "$?" = "0" ]; then
		HAVE_MANDOC="yes"
	fi
fi
if [ "${HAVE_MANDOC}" = "no" ]; then
	if [ "${with_manpages}" = "yes" ]; then
		echo "*"
		echo "* --with-manpages was requested, but either the nroff(1)"
		echo "* utility or the mdoc(7) macro package was not found."
		echo "*"
		exit 1
	fi
	echo "HAVE_MANDOC=no" >> Makefile.config
	echo "NOMAN=yes" >> Makefile.config
	echo "NOMANLINKS=yes" >> Makefile.config
else
	echo "HAVE_MANDOC=yes" >> Makefile.config
	if [ "${with_manpages}" = "no" ]; then
		echo "NOMAN=yes" >> Makefile.config
		echo "NOMANLINKS=yes" >> Makefile.config
	else
		if [ "${with_manlinks}" != "yes" ]; then
			echo "NOMANLINKS=yes" >> Makefile.config
		fi
	fi
fi
if [ "${with_docs}" = "no" ]; then
	echo "NODOC=yes" >> Makefile.config
fi

# Process NLS options.
if [ "${enable_nls}" = "yes" ]; then
	ENABLE_NLS="yes"
	echo "#ifndef ENABLE_NLS" > config/enable_nls.h
	echo "#define ENABLE_NLS 1" >> config/enable_nls.h
	echo "#endif /* ENABLE_NLS */" >> config/enable_nls.h
	msgfmt=""
	for path in `echo $PATH | sed 's/:/ /g'`; do
		if [ -x "${path}/msgfmt" ]; then
			msgfmt=${path}/msgfmt
		fi
	done
	if [ "${msgfmt}" != "" ]; then
		HAVE_GETTEXT="yes"
	else
		HAVE_GETTEXT="no"
	fi
else
	ENABLE_NLS="no"
	HAVE_GETTEXT="no"
	echo "#undef ENABLE_NLS" > config/enable_nls.h
fi
echo "ENABLE_NLS=${ENABLE_NLS}" >> Makefile.config
echo "HAVE_GETTEXT=${HAVE_GETTEXT}" >> Makefile.config

# Process ctags option.
CTAGS=""
if [ "${with_ctags}" = "yes" ]; then
	for path in `echo $PATH | sed 's/:/ /g'`; do
		if [ -x "${path}/ectags" ]; then
			CTAGS="${path}/ectags"
		fi
	done
	if [ "${CTAGS}" = "" ]; then
		for path in `echo $PATH | sed 's/:/ /g'`; do
			if [ -x "${path}/ctags" ]; then
				CTAGS="${path}/ctags"
			fi
		done
	fi
fi
echo "CTAGS=${CTAGS}" >> Makefile.config

# Default to bundled libtool.
LIBTOOL_BUNDLED="yes"
LIBTOOL=\${TOP}/mk/libtool/libtool
echo "LIBTOOL=${LIBTOOL}" >> Makefile.config

#
# Process the installation paths.
#
echo "PREFIX?=${PREFIX}" >> Makefile.config
echo "#ifndef PREFIX" > config/prefix.h
echo "#define PREFIX \"${PREFIX}\"" >> config/prefix.h
echo "#endif /* PREFIX */" >> config/prefix.h

if [ "${bindir}" != "" ]; then
	BINDIR="${bindir}"
else
	BINDIR="${PREFIX}/bin"
fi
echo "BINDIR=${BINDIR}" >> Makefile.config
echo "#ifndef BINDIR" > config/bindir.h
echo "#define BINDIR \"${BINDIR}\"" >> config/bindir.h
echo "#endif /* BINDIR */" >> config/bindir.h

if [ "${libdir}" != "" ]; then
	LIBDIR="${libdir}"
else
	LIBDIR="${PREFIX}/lib"
fi
echo "LIBDIR=${LIBDIR}" >> Makefile.config
echo "#ifndef LIBDIR" > config/libdir.h
echo "#define LIBDIR \"${LIBDIR}\"" >> config/libdir.h
echo "#endif /* LIBDIR */" >> config/libdir.h

if [ "${sharedir}" != "" ]; then
	SHAREDIR="${sharedir}"
else
	SHAREDIR="${PREFIX}/share"
fi
echo "SHAREDIR=${SHAREDIR}" >> Makefile.config
echo "#ifndef SHAREDIR" > config/sharedir.h
echo "#define SHAREDIR \"${SHAREDIR}\"" >> config/sharedir.h
echo "#endif /* SHAREDIR */" >> config/sharedir.h

if [ "${localedir}" != "" ]; then
	LOCALEDIR="${localedir}"
else
	LOCALEDIR="${SHAREDIR}/locale"
fi
echo "LOCALEDIR=${LOCALEDIR}" >> Makefile.config
echo "#ifndef LOCALEDIR" > config/localedir.h
echo "#define LOCALEDIR \"${LOCALEDIR}\"" >> config/localedir.h
echo "#endif /* LOCALEDIR */" >> config/localedir.h

if [ "${mandir}" != "" ]; then
	MANDIR="${mandir}"
else
	MANDIR="${SHAREDIR}/man"
fi
echo "MANDIR=${MANDIR}" >> Makefile.config
echo "#ifndef MANDIR" > config/mandir.h
echo "#define MANDIR \"${MANDIR}\"" >> config/mandir.h
echo "#endif /* MANDIR */" >> config/mandir.h

if [ "${infodir}" != "" ]; then
	INFODIR="${infodir}"
else
	INFODIR="${SHAREDIR}/info"
fi
echo "INFODIR=${INFODIR}" >> Makefile.config
echo "#ifndef INFODIR" > config/infodir.h
echo "#define INFODIR \"${INFODIR}\"" >> config/infodir.h
echo "#endif /* INFODIR */" >> config/infodir.h

if [ "${sysconfdir}" != "" ]; then
	SYSCONFDIR="${sysconfdir}"
else
	SYSCONFDIR="${PREFIX}/etc"
fi
echo "SYSCONFDIR=${SYSCONFDIR}" >> Makefile.config
echo "#ifndef SYSCONFDIR" > config/sysconfdir.h
echo "#define SYSCONFDIR \"${SYSCONFDIR}\"" >> config/sysconfdir.h
echo "#endif /* SYSCONFDIR */" >> config/sysconfdir.h

EOF
					$registers = 0;
				}
			}
			if ($cmd eq 'check' || $cmd eq 'require') {
				my $t = shift(@args);
				my $mod = "$INSTALLDIR/BSDBuild/$t.pm";
				unless (-e $mod) {
					print STDERR "$mod: $!\n";
					exit (1);
				}
				do($mod);
				if ($@) {
					print STDERR $@;
					exit (1);
				}
				if (exists($DEPS{$t})) {
					foreach my $dep (split(',',
					                 $DEPS{$t})) {
						if (!exists(
						    $done{$dep})) {
							print STDERR
							    "$t ".
							    "depends ".
							    "on: ".
							    $dep.
							    "\n";
							exit(1);
						}
					}
				}
	
				my $c;
				if ($EmulOS) {
					unless (exists($EMUL{$t}) &&
					        defined($EMUL{$t})) {
#						print STDERR
#						    "Ignoring: $t\n";
						next DIRECTIVE;
					}
					$c = $EMUL{$t};
					@args = ($EmulOS, $EmulOSRel,
					         '');
				} else {
					$c = $TESTS{$t};
					unless ($c) {
						die "Bad test: $t";
					}
				}
				print STDERR "+ $t: $DESCR{$t}\n";
				MkPrintN("checking for $DESCR{$t}...");
				&$c(@args);
				if ($EmulOS) {
					MkPrintN("ok\n");
				}
				$done{$t} = 1;
			} else {
				if (exists($Macros{$cmd})) {
					&{$Macros{$cmd}}(@args);
				}
			}
		} else {
			print $s, "\n";
		}
	}
}
