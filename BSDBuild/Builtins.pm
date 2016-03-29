# vim:ts=4
#
# Copyright (c) 2010-2016 Hypertriton, Inc. <http://hypertriton.com/>
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

use BSDBuild::Core;

# Built-in documentation stuff
sub BuiltinDoc
{
	print << 'EOF';
cat << EOT > conftest.1
.\" COMMENT
.Dd 
.Dd NOVEMBER 23, 2009
.Dt TEST 1
.Os
.ds vT Test
.ds oS Test 1.0
.Sh NAME
.Nm test
.Nd Test document
.Sh DESCRIPTION
EOT

HAVE_MANDOC="no"
MANDOC=""
bb_save_IFS=$IFS
IFS=$PATH_SEPARATOR
for path in $PATH; do
	if [ -x "${path}/mandoc" ]; then
		cat conftest.1 | ${path}/mandoc -Tascii >/dev/null
		if [ "$?" = "0" ]; then
			HAVE_MANDOC="yes"
			MANDOC="${path}/mandoc"
			break;
		fi
	elif [ -e "${path}/mandoc.exe" ]; then
		cat conftest.1 | ${path}/mandoc.exe -Tascii >/dev/null
		if [ "$?" = "0" ]; then
			HAVE_MANDOC="yes"
			MANDOC="${path}/mandoc.exe"
			break;
		fi
	elif [ -x "${path}/nroff" ]; then
		cat conftest.1 | ${path}/nroff -Tmandoc >/dev/null
		if [ "$?" = "0" ]; then
			HAVE_MANDOC="yes"
			MANDOC="${path}/nroff -Tmandoc"
			break;
		fi
	elif [ -e "${path}/nroff.exe" ]; then
		cat conftest.1 | ${path}/nroff.exe -Tmandoc >/dev/null
		if [ "$?" = "0" ]; then
			HAVE_MANDOC="yes"
			MANDOC="${path}/nroff.exe -Tmandoc"
			break;
		fi
	fi
done
IFS=$bb_save_IFS

rm -f conftest.1

if [ "${HAVE_MANDOC}" = "no" ]; then
	if [ "${with_manpages}" = "yes" ]; then
		echo "*"
		echo "* --with-manpages was requested, but either the"
		echo "* nroff(1)/mandoc(1) utility or the mdoc(7) macro"
		echo "* package were not found."
		echo "*"
		exit 1
	fi
	echo "HAVE_MANDOC=no" >> Makefile.config
	echo "NOMAN=yes" >> Makefile.config
	echo "NOMANLINKS=yes" >> Makefile.config
else
	echo "HAVE_MANDOC=yes" >> Makefile.config
	echo "MANDOC=${MANDOC}" >> Makefile.config
	if [ "${with_catman}" = "no" ]; then
		echo "NOCATMAN=yes" >> Makefile.config
	else
		if [ "${with_catman}" = "yes" ]; then
			echo "NOCATMAN=no" >> Makefile.config
		else
			case "${host}" in
			*-*-freebsd*)
				echo "NOCATMAN=yes" >> Makefile.config
				;;
			*)
				echo "NOCATMAN=no" >> Makefile.config
				;;
			esac
		fi
	fi
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
EOF
}

# Built-in NLS options
sub BuiltinNLS
{
	MkIfTrue('${enable_nls}');
		MkDefine('ENABLE_NLS', 'yes');
		MkSaveDefine('ENABLE_NLS');
		# XXX
		print << 'EOF';
msgfmt=""
bb_save_IFS=$IFS
IFS=$PATH_SEPARATOR
for path in $PATH; do
	if [ -x "${path}/msgfmt" ]; then
		msgfmt=${path}/msgfmt
		break
	elif [ -e "${path}/msgfmt.exe" ]; then
		msgfmt=${path}/msgfmt.exe
		break
	fi
done
IFS=$bb_save_IFS

if [ "${msgfmt}" != "" ]; then
	HAVE_GETTEXT="yes"
else
	HAVE_GETTEXT="no"
fi
EOF
		MkSaveDefine('ENABLE_NLS');
	MkElse;
		MkDefine('ENABLE_NLS', 'no');
		MkDefine('HAVE_GETTEXT', 'no');
		MkSaveUndef('ENABLE_NLS');
	MkEndif;
	MkSaveMK('ENABLE_NLS', 'HAVE_GETTEXT');
}

# Built-in ctags options.
sub BuiltinCtags
{
	print << 'EOF';
CTAGS=""
bb_save_IFS=$IFS
IFS=$PATH_SEPARATOR
if [ "${with_ctags}" = "yes" ]; then
	for path in $PATH; do
		if [ -x "${path}/ectags" ]; then
			CTAGS="${path}/ectags"
			break
		elif [ -e "${path}/ectags.exe" ]; then
			CTAGS="${path}/ectags.exe"
			break
		fi
	done
	if [ "${CTAGS}" = "" ]; then
		for path in $PATH; do
			if [ -x "${path}/ctags" ]; then
				CTAGS="${path}/ctags"
				break
			elif [ -e "${path}/ctags.exe" ]; then
				CTAGS="${path}/ctags.exe"
				break
			fi
		done
	fi
fi
IFS=$bb_save_IFS
echo "CTAGS=${CTAGS}" >> Makefile.config
EOF
}

sub BuiltinLibtool
{
	# Default to bundled libtool
	print << 'EOF';
if [ "${prefix_libtool}" != "" -a "${prefix_libtool}" != "bundled" ]; then
	LIBTOOL_BUNDLED="no"
	LIBTOOL="${prefix_libtool}"
else
	LIBTOOL_BUNDLED="yes"
	LIBTOOL=\${TOP}/mk/libtool/libtool
fi
echo "LIBTOOL_BUNDLED=${LIBTOOL_BUNDLED}" >> Makefile.config
echo "LIBTOOL=${LIBTOOL}" >> Makefile.config
EOF
}

BEGIN
{
    require Exporter;

    @ISA = qw(Exporter);
    @EXPORT = qw(BuiltinDoc BuiltinNLS BuiltinCtags BuiltinLibtool);
}

;1
