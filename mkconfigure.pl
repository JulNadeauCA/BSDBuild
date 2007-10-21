#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2001-2007 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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

sub mdefine
{
	my ($def, $val) = @_;
	
	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveMK($def);
	PmComment("$def = $val");
}

sub hdefine
{
	my ($def, $val) = @_;

	if ($val =~ /^"(.+)"$/) { $val = $1; }
	MkDefine($def, $val);
	MkSaveDefine($def);
}

sub hundef
{
	my $def = shift;
	MkSaveUndef($def);
	PmComment("$def = undef");
}

sub c_define
{
	my $def = shift;

	MkDefine('CFLAGS', '$CFLAGS -D'.$def);
	MkDefine('CXXFLAGS', '$CXXFLAGS -D'.$def);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');
	PmDefineBool($def);
}

sub c_incdir
{
	my $dir = shift;
	
	MkDefine('CFLAGS', '$CFLAGS -I'.$dir);
	MkDefine('CXXFLAGS', '$CXXFLAGS -I'.$dir);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');

	$dir =~ s/\$SRC/\./g;
	PmIncludePath($dir);
}

sub c_libdir
{
	my $def = shift;

	MkDefine('LIBS', '$LIBS -L'.$def);
	MkSaveMK('LIBS');

	$dir =~ s/\$SRC/\./g;
	PmLibPath($dir);
}

sub c_extra_warnings
{
	PmBuildFlag('extra-warnings');
}

sub c_fatal_warnings
{
	PmBuildFlag('extra-warnings');
}

sub c_no_secure_warnings
{
	PmDefineBool('_CRT_SECURE_NO_WARNINGS');
}

sub c_option
{
	my $opt = shift;

	MkDefine('CFLAGS', '$CFLAGS '.$opt);
	MkDefine('CXXFLAGS', '$CXXFLAGS '.$opt);
	MkSaveMK('CFLAGS');
	MkSaveMK('CXXFLAGS');
}

sub Register
{
	my ($arg, $descr) = @_;
	$arg =~ /\"(.*)\"/;
	$arg = $1;
	$descr =~ /\"(.*)\"/;
	$descr = $1;

	my $darg = pack('A' x 30, split('', $arg));
	push @HELP, "echo \"    $darg $descr\"";
}

sub Help
{
    my $prefix_opt = pack('A' x 30, split('', '--prefix'));
    my $sysconfdir_opt = pack('A' x 30, split('', '--sysconfdir'));
    my $sharedir_opt = pack('A' x 30, split('', '--sharedir'));
    my $localedir_opt = pack('A' x 30, split('', '--localedir'));
    my $srcdir_opt = pack('A' x 30, split('', '--srcdir'));
    my $help_opt = pack('A' x 30, split('', '--help'));
    my $nls_opt = pack('A' x 30, split('', '--enable-nls'));
    my $gettext_opt = pack('A' x 30, split('', '--with-gettext'));
    my $libtool_opt = pack('A' x 30, split('', '--with-libtool'));
    my $manpages_opt = pack('A' x 30, split('', '--with-manpages'));
    my $docs_opt = pack('A' x 30, split('', '--with-docs'));
    my $debug_opt = pack('A' x 30, split('', '--enable-debug'));

    my $regs = join("\n",
        "echo \"    $prefix_opt Installation prefix [/usr/local]\"",
        "echo \"    $sysconfdir_opt System-wide configuration prefix [/etc]\"",
        "echo \"    $sharedir_opt Share prefix [\$PREFIX/share]\"",
        "echo \"    $localedir_opt Locale prefix [\$PREFIX/share/locale]\"",
        "echo \"    $srcdir_opt Source tree for concurrent build [.]\"",
        "echo \"    $help_opt Display this message\"",
        "echo \"    $nls_opt Native Language Support [no]\"",
        "echo \"    $gettext_opt Use gettext tools (msgmerge, ...) [check]\"",
        "echo \"    $libtool_opt Specify path to libtool [check]\"",
        "echo \"    $manpages_opt Manual pages (-mdoc) [yes]\"",
        "echo \"    $docs_opt Printable docs (-me/tbl/eqn/pic/refer) [no]\"",
        "echo \"    $debug_opt Include debugging code [no]\"",
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

BEGIN
{
	$INSTALLDIR = '%PREFIX%/share/bsdbuild';

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

	open($LUA, '>configure.lua');
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
EOF

	print << 'EOF';
# Copyright (c) 2001-2007 Hypertriton, Inc. <http://hypertriton.com/>
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
	--sharedir=*)
	    sharedir=$optarg
	    ;;
	--localedir=*)
	    localedir=$optarg
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
	*)
	    echo "invalid argument: $arg"
	    echo "try ./configure --help"
	    exit 1
	    ;;
	esac
done

if [ "${prefix}" != "" ]; then
    PREFIX="$prefix"
else
    PREFIX="/usr/local"
fi

if [ "${srcdir}" != "" ]; then
	echo "concurrent build (source in ${srcdir})"
	SRC=${srcdir}
	perl ${SRC}/mk/mkconcurrent.pl ${SRC}
	if [ $? != 0 ]; then
		exit 1;
	fi
else
	SRC=`pwd`
fi
EOF

	my $registers = 1;
	while (<STDIN>) {
		chop;
		if (/^\s*#/) {
		    next;
		}
		foreach my $s (split(';')) {
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
echo "Host: $HOST"

echo "# File generated by configure script (BSDbuild %VERSION%)." > Makefile.config
echo "Machine: $MACHINE" > config.log
echo "Release: $OSRELEASE" >> config.log
echo "System: $SYSTEM" >> config.log
for arg
do
	echo "Argument: $arg" >> config.log
done
mkdir config 1>/dev/null 2>&1

HAVE_MANDOC="no"
NROFF=""
for path in `echo $PATH | sed 's/:/ /g'`; do
	if [ -x "${path}/nroff" ]; then
		NROFF="${path}/nroff"
	fi
done
if [ "${NROFF}" != "" ]; then
	echo | ${NROFF} -Tmandoc >/dev/null
	if [ $? == 0 ]; then
		HAVE_MANDOC="yes"
	fi
fi
if [ "${HAVE_MANDOC}" = "no" ]; then
	if [ "${with_manpages}" = "yes" ]; then
		echo "*"
		echo "* --with-manpages requested, but nroff/mandoc not found."
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
	fi
fi

if [ "${with_docs}" = "no" ]; then
	echo "NODOC=yes" >> Makefile.config
fi
if [ "${enable_debug}" = "yes" ]; then
	echo "LDFLAGS+=-g" >> Makefile.config
	echo "#ifndef DEBUG" > config/debug.h
	echo "#define DEBUG 1" >> config/debug.h
	echo "#endif /* DEBUG */" >> config/debug.h
else
	echo "#undef DEBUG" > config/debug.h
fi

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

echo -n "checking for libtool..."
LIBTOOL_BUNDLED="no"
if [ "${with_libtool}" != "" ]; then
	LIBTOOL=${with_libtool}
else
	ltool=""
	for path in `echo $PATH | sed 's/:/ /g'`; do
		if [ -x "${path}/libtool" ]; then
			ltool=${path}/libtool
		fi
	done
	if [ "${ltool}" != "" ]; then
		${ltool} --version 1>/dev/null 2>&1
		if [ $? == 0 ]; then
			LIBTOOL=${ltool}
		else
			LIBTOOL=\${TOP}/mk/libtool/libtool
			LIBTOOL_BUNDLED="yes"
		fi
	else
		LIBTOOL=\${TOP}/mk/libtool/libtool
		LIBTOOL_BUNDLED="yes"
	fi
fi
if [ "${LIBTOOL_BUNDLED}" = "yes" ]; then
	echo "yes (bundled)"
else
	grep ^VERSION=1.5 "${LIBTOOL}" 1>/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "yes (GNU libtool 1.5)"
		echo "LIBTOOLFLAGS=-prefer-pic" >> Makefile.config
	else
		echo "yes (GNU libtool)"
	fi
fi
echo "LIBTOOL=${LIBTOOL}" >> Makefile.config

echo "PREFIX?=${PREFIX}" >> Makefile.config
echo "#ifndef PREFIX" > config/prefix.h
echo "#define PREFIX \"${PREFIX}\"" >> config/prefix.h
echo "#endif /* PREFIX */" >> config/prefix.h

if [ "${sharedir}" != "" ]; then
	echo "SHAREDIR=${sharedir}" >> Makefile.config
	echo "#ifndef SHAREDIR" > config/sharedir.h
	echo "#define SHAREDIR \"${sharedir}\"" >> config/sharedir.h
	echo "#endif /* SHAREDIR */" >> config/sharedir.h
	SHAREDIR="${sharedir}"
else
	echo "SHAREDIR=\${PREFIX}/share" >> Makefile.config
	echo "#ifndef SHAREDIR" > config/sharedir.h
	echo "#define SHAREDIR \"${SHAREDIR}\"" >> config/sharedir.h
	echo "#endif /* SHAREDIR */" >> config/sharedir.h
	SHAREDIR="${PREFIX}/share"
fi

if [ "${localedir}" != "" ]; then
	LOCALEDIR="${localedir}"
	echo "LOCALEDIR=${LOCALEDIR}" >> Makefile.config
	echo "#ifndef LOCALEDIR" > config/localedir.h
	echo "#define LOCALEDIR \"${LOCALEDIR}\"" >> config/localedir.h
	echo "#endif /* LOCALEDIR */" >> config/localedir.h
else
	LOCALEDIR="${SHAREDIR}/locale"
	echo "LOCALEDIR=\${SHAREDIR}/locale" >> Makefile.config
	echo "#ifndef LOCALEDIR" > config/localedir.h
	echo "#define LOCALEDIR \"${LOCALEDIR}\"" >> config/localedir.h
	echo "#endif /* LOCALEDIR */" >> config/localedir.h
fi

if [ "${sysconfdir}" != "" ]; then
	SYSCONFDIR="${sysconfdir}"
	echo "SYSCONFDIR=${sysconfdir}" >> Makefile.config
	echo "#ifndef SYSCONFDIR" > config/sysconfdir.h
	echo "#define SYSCONFDIR \"${SYSCONFDIR}\"" >> config/sysconfdir.h
	echo "#endif /* SYSCONFDIR */" >> config/sysconfdir.h
else
	SYSCONFDIR="${PREFIX}/etc"
	echo "SYSCONFDIR=\${PREFIX}/etc" >> Makefile.config
	echo "#ifndef SYSCONFDIR" > config/sysconfdir.h
	echo "#define SYSCONFDIR \"${SYSCONFDIR}\"" >> config/sysconfdir.h
	echo "#endif /* SYSCONFDIR */" >> config/sysconfdir.h
fi

EOF
						$registers = 0;
					}
				}

				if ($cmd eq 'check' || $cmd eq 'require') {
					my $app = shift(@args);
					my $mod = "$INSTALLDIR/BSDBuild/".
					          "${app}.pm";
					
					unless (-e $mod) {
						print STDERR "$mod: $!\n";
						exit (1);
					}
					do($mod);
					if ($@) {
						print STDERR $@;
						exit (1);
					}
					my $c = $TESTS{$app};
					unless ($c) {
						die "missing test";
					}
					print STDERR "+ $app: $DESCR{$app}\n";
					MkPrintN("checking for ".
					         "$DESCR{$app}...");
					&$c(@args);
				} elsif ($cmd eq 'mdefine') {
					mdefine(@args);
				} elsif ($cmd eq 'hdefine') {
					hdefine(@args);
				} elsif ($cmd eq 'hundef') {
					hundef(@args);
				} elsif ($cmd eq 'c_define') {
					c_define(@args);
				} elsif ($cmd eq 'c_incdir') {
					c_incdir(@args);
				} elsif ($cmd eq 'c_libdir') {
					c_libdir(@args);
				} elsif ($cmd eq 'c_option') {
					c_option(@args);
				} elsif ($cmd eq 'c_extra_warnings') {
					c_extra_warnings(@args);
				} elsif ($cmd eq 'c_fatal_warnings') {
					c_fatal_warnings(@args);
				} elsif ($cmd eq 'c_no_secure_warnings') {
					c_no_secure_warnings(@args);
				} elsif ($cmd eq 'exit') {
					print "exit $args[0]\n";
				}
			} else {
				print $s, "\n";
			}
		}
	}
	MkPrint("Don't forget to run \\\"make depend\\\".");
}

