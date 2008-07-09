#!/usr/bin/perl
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com>
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

#
# Create a mandoc template from one or more C header files.
#

my @lines = ();
my $cdecls = 0;

print << 'EOF';
.\" Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
.\" All rights reserved.
.\"
.\" Redistribution and use in source and binary forms, with or without
.\" modification, are permitted provided that the following conditions
.\" are met:
.\" 1. Redistributions of source code must retain the above copyright
.\"    notice, this list of conditions and the following disclaimer.
.\" 2. Redistributions in binary form must reproduce the above copyright
.\"    notice, this list of conditions and the following disclaimer in the
.\"    documentation and/or other materials provided with the distribution.
.\" 
.\" THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
.\" IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
.\" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
.\" ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
.\" INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
.\" (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
.\" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
.\" HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
.\" STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
.\" IN ANY WAY OUT OF THE USE OF THIS SOFTWARE EVEN IF ADVISED OF THE
.\" POSSIBILITY OF SUCH DAMAGE.
.\"
.Dd November 18, 2008
.Dt FOO 3
.Os
.ds vT FOO API Reference
.ds oS FOO 1.3
.Sh NAME
.Nm FOO
.Nd FOOtitle
.Sh SYNOPSIS
.Bd -literal
#include <FOO/FOO.h>
.Ed
.Sh DESCRIPTION
The
.Nm
interface provides...
.Sh INTERFACE
.nr nS 1
EOF

foreach $_ (@ARGV) {
	open(F, $_) || die "$_: $!";
	foreach my $line (<F>) {
		chop($line);
		if ($line =~ /^__(BEGIN|END)_DECLS/) {
			$cdecls++;
		}
		push @lines, $line;
	}
	close(F);
}

my $eval = 0;
my $elines = '';
foreach $_ (@lines) {
	if ($cdecls) {
		if (/^__BEGIN_DECLS/) { $eval = 1; next }
		if (/^__END_DECLS/) { $eval = 0; next }
	}
	if ($eval) { $elines .= $_."\n"; }
}
foreach $_ (split(';', $elines)) {
	if (/^#/) { next; }
	if (/^\s*static\s+__inline__
	      \s+([\w\s]+\s+\*{0,1})\s*([\(\)\w\*\s,]+)/mx ||
	    /([\w\s]+\s+\*{0,1})\s*([\(\)\w\*\s,]+)/m) {
		my $type = $1;
		my $args = $2;
		while ($type =~ /\s$/) { chop($type); }
		$type =~ s/([\w\*]+)\s+([\w\*]+)/$1 $2/;
		if ($args =~ /^(\w+)\(([\w\*\s,]+)\)$/) {
			my $fnName = $1;
			my $argList = $2;
			$type =~ s/\n//g;
			print '.Ft "'.$type."\"\n";
			print '.Fn '.$fnName;
			foreach my $arg (split(',', $argList)) {
				$arg =~ s/\s*([\w\s]+)\s*/$1/g;
				print ' "'.$arg.'"';
			}
			print "\n.Pp\n";
		}
	}
}

print << 'EOF';
.nr nS 0
.Sh SEE ALSO
.Xr FOO 3
.Sh HISTORY
The
.Nm
interface first appeared in FOO 1.3.
.nr nS 0
EOF
