#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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

#
# Read a BSDBuild Makefile on standard input and output the Premake script
# which will be used by <build.proj.mk> to generate IDE project files.
# 
# The following BSDBuild variables are recognized:
#
#	SUBDIR		-> Recurse using Premake dopackage()
#	PROJECT		-> Premake project name
#	PROJECT_GUID	-> Project GUID
#	LIB		-> Use as output library name
#	LIB_GUID	-> Library GUID
#	LIB_LINKS	-> Explicitely linked libraries (for non-Unix platforms)
#	LIB_SHARED	-> Produce dynamic linkable libraries
#	LIB_STATIC	-> Produce static libraries
#	PROG		-> Use as output program name
#	PROG_GUID	-> Program GUID
#	PROG_LINKS	-> Explicitely linked libraries (for non-Unix platforms)
#	PROG_TYPE	-> Set program interface ("GUI" or "CLI")
#	SRCS		-> List of source files
#	CFLAGS		-> Compiler options, used as follows:
#
#		-I<pathname>	-> Add to package.includepaths
#		-D<define>	-> Add to package.defines

use BSDBuild::Core;

my $projFlav = '';
my $Error = '';
my %linkFn = ();
my %V = ();

sub Version
{
    print << "EOF";
echo "BSDbuild %VERSION%"
exit 1
EOF
}

sub DoProject
{
	print << "EOF";
project.name = "$V{'PROJECT'}"
EOF
	if (exists($V{'PROJECT_GUID'}) && $V{'PROJECT_GUID'}) {
		print "project.guid = \"$V{'PROJECT_GUID'}\"\n";
	}
	if (exists($V{'SUBDIR'})) {
		my @subdirs = split(' ', $V{'SUBDIR'});
		foreach my $subdir (@subdirs) {
			if ($subdir =~ /^\s*(.+)\*$/) { $subdir = $1; }
			unless ($subdir) {
				next;
			}
			print "dopackage(\"$subdir\")\n";
		}
	}
}

sub DoPackage ($$$)
{
	my ($name, $kind, $lang) = @_;

	unless ($name) {
		#print STDERR "Unable to determine package name\n";
		exit (0);
	}
	print << "EOF";
package = newpackage()
package.name = "$name"
package.kind = "$kind"
package.language = "$lang"
EOF
	if (exists($V{'PROG_GUID'}) && $V{'PROG_GUID'}) {
		print "package.guid = \"$V{'PROG_GUID'}\"\n";
	} elsif (exists($V{'LIB_GUID'}) && $V{'LIB_GUID'}) {
		print "package.guid = \"$V{'LIB_GUID'}\"\n";
	}
	if ($ENV{'PROJFLAVOR'}) {
		$projFlav = $ENV{'PROJFLAVOR'};
	}
	if ($ENV{'PROJINCLUDES'}) {
		foreach my $incl (split(' ', $ENV{'PROJINCLUDES'})) {
			print "dofile(\"$incl\")\n";
		}
	}

	my $links = '';
	if (exists($V{'PROG_LINKS'}) && $V{'PROG_LINKS'}) {
		$links = $V{'PROG_LINKS'};
	} elsif (exists($V{'LIB_LINKS'}) && $V{'LIB_LINKS'}) {
		$links = $V{'LIB_LINKS'};
	}
	if ($links) {
		foreach my $ln (split(' ', $links)) {
			my $handled = 0;
			foreach my $fn (values %linkFn) {
				if (&$fn($ln)) { $handled++; }
			}
			if (!$handled) {
				print "tinsert(package.links,{\"$ln\"})\n";
			}
		}
	}
	if (exists($V{'SRCS'}) && $V{'SRCS'}) {
		print 'package.files = {', "\n";
		foreach my $src (split(' ', $V{'SRCS'})) {
			if ($src =~ /^\s*(.+)\*$/) { $src = $1; }
			next unless $src;
			print "\t\"$src\",\n";
		}
		print '}', "\n";
	}
	if (exists($V{'CFLAGS'}) && $V{'CFLAGS'}) {
		my @cflags = split(' ', $V{'CFLAGS'});
		foreach my $cflag (@cflags) {
			my $handled = 0;
			if ($cflag =~ /^-I\s*([\w\-\.\/]+)\s*$/) {
				print "tinsert(package.includepaths,".
				      "{\"$1\"})\n";
				next;
			}
			if ($cflag =~ /^-D\s*(\w+)\s*$/) {
				print "tinsert(package.defines,".
				      "{\"$1\"})\n";
				next;
			}
			if ($cflag =~ /^\${([\w\-\.]+)}$/) { $cflag = $1; }
			elsif ($cflag =~ /^\$([\w\-\.]+)$/) { $cflag = $1; }
			#foreach my $fn (values %cflagSubstFn) {
			#	if (&$fn($projFlav, 'CFLAGS', $cflag)) {
			#		$handled++;
			#	}
			#}
			#if (!$handled) {
			#	print STDERR "* CFLAGS: Not substituting: ".
			#	             "\"$cflag\"\n";
			#}
		}
	}
	if (exists($V{'LIBS'}) && $V{'LIBS'}) {
		my @libs = split(' ', $V{'LIBS'});
		foreach my $lib (@libs) {
			my $handled = 0;
			if ($lib =~ /^\${([\w\-\.]+)}$/) { $lib = $1; }
			elsif ($lib =~ /^\$([\w\-\.]+)$/) { $lib = $1; }
			#foreach my $fn (values %libsSubstFn) {
			#	if (&$fn($projFlav, 'LIBS', $lib)) {
			#		$handled++;
			#	}
			#}
			#if (!$handled) {
			#	print STDERR "Ignoring LIBS: $lib\n";
			#}
		}
	}
}

sub ParseMakefile ($)
{
	my $file = shift;
	my @lines = ();
	my $line = '';
	my $incl;

	unless (open($incl, $file)) {
		$Error = "$file: $!";
		return (0);
	}

	# Parse the Makefile looking for specific variables.
	foreach $_ (<$incl>) {
		chop;

		if (/^(.+)\\$/) {			# Expansion
			$line .= $1;
		} else {				# New line
			if ($line) {
				push @lines, $line . $_;
				$line = '';
			} else {
				push @lines, $_;
			}
		}
	}
	foreach $_ (@lines) {
		if (/^\s*#/) { next; }
		if (/^\t/) { next; }

		s/\$\{(\w+)\}/$V{$1}/g;

		if (/^\s*(\w+)\s*=\s*"(.+)"$/ ||
		    /^\s*(\w+)\s*=\s*(.+)$/) {
			$V{$1} = $2;
		} elsif (/^\s*(\w+)\s*\+=\s*"(.+)"$/ ||
		         /^\s*(\w+)\s*\+=\s*(.+)$/) {
			if (exists($V{$1}) && $V{$1} ne '') {
				$V{$1} .= ' '.$2;
			} else {
				$V{$1} = $2;
			}
		}

		if (/^\s*include\s+(.+)$/) {
			my $incl = $1;
			if (!ParseMakefile($incl)) {
				$Error = "($incl): $Error";
				return (0);
			}
		}
	}
	close($incl);
	return (1);
}

if (!ParseMakefile('-')) {
	print STDERR "$Error\n";
	exit(1);
}
if (exists($V{'PROJECT'}) && $V{'PROJECT'}) {
	DoProject();
}

my $packLang = 'c';
my %langs = ();

if (exists($V{'SRCS'}) && $V{'SRCS'}) {
	foreach my $src (split(' ', $V{'SRCS'})) {
		if ($src =~ /\.c$/i) { $langs{'c'} = 1; }
		elsif ($src =~ /\.(cc|cpp)$/i) { $langs{'c++'} = 1; }
		elsif ($src =~ /\.cs$/i) { $langs{'c#'} = 1; }
	}
}
if (exists($langs{'c'})) {
	if (exists($langs{'c++'})) {
 	   	print STDERR "*\n".
		             "* WARNING: Package contains both C and C++\n".
			     "* source files.\n".
			     "*\n";
		$packLang = 'c++';
	} elsif (exists($langs{'c#'})) {
 	   	print STDERR "*\n".
		             "* WARNING: Package contains both C and C#\n".
			     "* source files.\n".
			     "*\n";
		$packLang = 'c#';
	}
} elsif (exists($langs{'c++'})) {
	$packLang = 'c++';
} elsif (exists($langs{'c#'})) {
	$packLang = 'c#';
}
print STDERR "* Using package language: $packLang\n";

if (exists($V{'LIB'}) && $V{'LIB'}) {
	if (exists($V{'LIB_SHARED'}) &&
	    uc($V{'LIB_SHARED'}) eq 'YES') {
		DoPackage($V{'LIB'}.'_static', 'lib', $packLang);
		DoPackage($V{'LIB'}, 'dll', $packLang);
	} else {
		DoPackage($V{'LIB'}, 'lib', $packLang);
	}
} elsif (exists($V{'PROG'}) && $V{'PROG'}) {
	if (exists($V{'PROG_TYPE'}) && uc($V{'PROG_TYPE'}) eq 'GUI') {
		DoPackage($V{'PROG'}, 'winexe', $packLang);
	} else {
		DoPackage($V{'PROG'}, 'exe', $packLang);
	}
} else {
	print STDERR "Unable to determine package kind\n";
	exit (0);
}

# $EmulFoo is required by some tests.
$EmulEnv = $ENV{'PROJTARGET'};
$EmulOS = $ENV{'PROJOS'};

# Map the LINK routine of every module.
$INSTALLDIR = '%PREFIX%/share/bsdbuild';
if (opendir(DIR, $INSTALLDIR.'/BSDBuild')) {
	foreach my $file (readdir(DIR)) {
		my $path = $INSTALLDIR.'/BSDBuild/'.$file;
		if ($file =~ /^\./ || $file =~ /^[A-Z]/ || !-f $path) { next; }
		if ($file !~ /^([\w\-\.]+)\.pm$/) { next; }
		my $modname = $1;
		do($path);
		if ($@) {
			print STDERR "Module failed: $modname: $@\n";
			exit (1);
		}
		if (exists($LINK{$modname}) &&
		    defined($LINK{$modname})) {
			$linkFn{$modname} = $LINK{$modname};
		}
	}
	closedir(DIR);
}
print << 'EOF';
--
-- Do not edit!
-- This file was generated from Makefile by BSDbuild %VERSION%.
--
-- To regenerate this file, get the latest BSDbuild release from
-- http://hypertriton.com/bsdbuild/, the latest Premake release
-- (v3 series) from http://premake.sourceforge.net/, and execute:
--
--     $ make proj
--
EOF

