#!/usr/bin/perl -I%PREFIX%/share/csoft-mk
#
# $Csoft: manuconf.pl,v 1.43 2005/02/07 13:23:57 vedge Exp $
#
# Copyright (c) 2001, 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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
use Manuconf::Core;

sub MDefine;

sub Register;
sub Help;
sub Version;

sub MDefine
{
	my ($def, $val) = @_;

	print
	    Define($def, $val) .
	    MKSave($def);
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
echo "Csoft-mk %VERSION%"
exit 1
EOF
}

BEGIN
{
	$INSTALLDIR = '%PREFIX%/share/csoft-mk';

	print << "EOF";
#!/bin/sh
#
# Do not edit!
# File generated from configure.in by csoft-mk %VERSION%.
#
EOF

	print << 'EOF';
# Copyright (c) 2001, 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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
	    case "$option" in
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
	    case "$option" in
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
    PREFIX=$prefix
else
    PREFIX=/usr/local
fi
if [ "${sysconfdir}" != "" ]; then
    SYSCONFDIR=$sysconfdir
else
    SYSCONFDIR=/etc
fi
if [ "${sharedir}" != "" ]; then
    SHAREDIR=$sharedir
else
    SHAREDIR=${PREFIX}/share
fi
if [ "${localedir}" != "" ]; then
    LOCALEDIR=$localedir
else
    LOCALEDIR=${SHAREDIR}/locale
fi

if [ "${srcdir}" != "" ]; then
	echo "concurrent build (source in ${srcdir})"
#	if [ ! -e "${srcdir}" ]; then
#		echo "Cannot find source directory: ${srcdir}"
#		exit 1
#	fi
#	if [ ! -e "${srcdir}/configure.in" ]; then
#		echo "Invalid source directory: ${srcdir}"
#		exit 1
#	fi
#	if [ -e "${srcdir}/config" ]; then
#		echo "Source directory is already configured: ${srcdir}"
#		exit 1
#	fi
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
		if (/^#/) {
		    next;
		}
		foreach my $s (split(';')) {
			if ($s =~ /([A-Z]+)\((.*)\)/) {
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
RELEASE=`uname -r 2>/dev/null` || RELEASE=unknown
SYSTEM=`uname -s 2>/dev/null` || SYSTEM=unknown
HOST="$SYSTEM-$RELEASE-$MACHINE"
echo "Host: $HOST"

echo > Makefile.config
echo "Machine: $MACHINE" > config.log
echo "Release: $RELEASE" >> config.log
echo "System: $SYSTEM" >> config.log
mkdir config 1>/dev/null 2>&1

if [ "${with_manpages}" = "no" ]; then
    echo "NOMAN=yes" >> Makefile.config
fi
if [ "${with_docs}" = "no" ]; then
    echo "NODOC=yes" >> Makefile.config
fi
if [ "${enable_debug}" = "yes" ]; then
	echo "LDFLAGS=-g" >> Makefile.config
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
		echo "LOCALEDIR=${LOCALEDIR}" >> Makefile.config
		echo "#ifndef LOCALEDIR" > config/localedir.h
		echo "#define LOCALEDIR \"${LOCALEDIR}\"" >> config/localedir.h
		echo "#endif /* LOCALEDIR */" >> config/localedir.h
	else
		HAVE_GETTEXT="no"
		echo "#undef LOCALEDIR" > config/localedir.h
	fi
else
	ENABLE_NLS="no"
	HAVE_GETTEXT="no"
	echo "#undef ENABLE_NLS" > config/enable_nls.h
	echo "#undef LOCALEDIR" > config/localedir.h
fi
echo "ENABLE_NLS=${ENABLE_NLS}" >> Makefile.config
echo "HAVE_GETTEXT=${HAVE_GETTEXT}" >> Makefile.config

echo "PREFIX=${PREFIX}" >> Makefile.config
echo "#ifndef PREFIX" > config/prefix.h
echo "#define PREFIX \"${PREFIX}\"" >> config/prefix.h
echo "#endif /* PREFIX */" >> config/prefix.h

echo "SHAREDIR=${SHAREDIR}" >> Makefile.config
echo "#ifndef SHAREDIR" > config/sharedir.h
echo "#define SHAREDIR \"${SHAREDIR}\"" >> config/sharedir.h
echo "#endif /* SHAREDIR */" >> config/sharedir.h

echo "SYSCONFDIR=${SYSCONFDIR}" >> Makefile.config
echo "#ifndef SYSCONFDIR" > config/sysconfdir.h
echo "#define SYSCONFDIR \"${SYSCONFDIR}\"" >> config/sysconfdir.h
echo "#endif /* SYSCONFDIR */" >> config/sysconfdir.h

echo "LOCALEDIR=${LOCALEDIR}" >> Makefile.config
echo "#ifndef LOCALEDIR" > config/localedir.h
echo "#define LOCALEDIR \"${LOCALEDIR}\"" >> config/localedir.h
echo "#endif /* LOCALEDIR */" >> config/localedir.h
EOF
						$registers = 0;
					}
				}

				if ($cmd eq 'check' || $cmd eq 'require') {
					my $app = shift(@args);
					my $mod =
					  "$INSTALLDIR/Manuconf/${app}.pm";
					
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
					print NEcho(
					"checking for $DESCR{$app}...");
					&$c(@args);
				} elsif ($cmd eq 'mdefine') {
				    MDefine(@args);
				} elsif ($cmd eq 'hdefine') {
				    print Define($args[0], $args[1]) .
				          HDefine($args[0]);
				} elsif ($cmd eq 'hundef') {
					print HUndef($args[0]);
				} elsif ($cmd eq 'exit') {
				    print "exit $args[0]\n";
				}
			} else {
				print $s, "\n";
			}
		}
	}
	print Echo("Don't forget to run \\\"make depend\\\".");
}

