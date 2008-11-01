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
# Premake project information is obtained from assignments to the standard
# BSDBuild variables:
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

my @lines = ();
my $line = '';
my $projFlav = '';

my $libName = undef;
my $progName = undef;
my $progGUI = 0;

my $libShared = 0;
my $libStatic = 1;

my @subdirs = ();
my @srcs = ();
my @cflags = ();
my @libs = ();

my $project = '';
my $projGUID = '';
my $pkgGUID = '';
my $pkgLinks = '';

my %linkFn = ();

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
project.name = "$project"
EOF
	if ($projGUID) {
		print "project.guid = \"$projGUID\"\n";
	}
	if (@subdirs) {
		foreach my $subdir (@subdirs) {
			if ($subdir =~ /^\s*(.+)\*$/) { $subdir = $1; }
			next unless $subdir;
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
	if ($pkgGUID) {
		print "package.guid = \"$pkgGUID\"\n";
	}
	if ($ENV{'PROJFLAVOR'}) {
		$projFlav = $ENV{'PROJFLAVOR'};
	}
	if ($ENV{'PROJINCLUDES'}) {
		foreach my $incl (split(' ', $ENV{'PROJINCLUDES'})) {
			print "dofile(\"$incl\")\n";
		}
	}
	if ($pkgLinks) {
		foreach my $ln (split(' ', $pkgLinks)) {
			my $handled = 0;
			foreach my $fn (values %linkFn) {
				if (&$fn($ln)) { $handled++; }
			}
			if (!$handled) {
				print "tinsert(package.links,{\"$ln\"})\n";
			}
		}
	}
	if (@srcs) {
		print 'package.files = {', "\n";
		foreach my $src (@srcs) {
			if ($src =~ /^\s*(.+)\*$/) { $src = $1; }
			next unless $src;
			print "\t\"$src\",\n";
		}
		print '}', "\n";
	}
	if (@cflags) {
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
	if (@libs) {
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

# $EmulFoo is required by some tests.
$EmulEnv = $ENV{'PROJTARGET'};
$EmulOS = $ENV{'PROJOS'};
$EmulArch = $ENV{'PROJARCH'};

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

# Parse the Makefile looking for specific variables.
foreach $_ (<STDIN>) {
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
	if (/^\s*PROJECT\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$project = $1;
	}
	elsif (/^\s*PROJECT_GUID\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$projGUID = $1;
	}
	elsif (/^\s*LIB\s*=\s*([\w\-\.]+)\s*$/) {
		$libName = $1;
	}
	elsif (/^\s*LIB_GUID\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$pkgGUID = $1;
	}
	elsif (/^\s*LIB_LINKS\s*=\s*\"*\s*([\w\-\.\s]+)\s*\"*\s*$/) {
		$pkgLinks = $1;
	}
	elsif (/^\s*PROG\s*=\s*([\w\-\.]+)\s*$/) {
		$progName = $1;
	}
	elsif (/^\s*PROG_GUID\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$pkgGUID = $1;
	}
	elsif (/^\s*PROG_LINKS\s*=\s*\"*\s*([\w\-\.\s]+)\s*\"*\s*$/) {
		$pkgLinks = $1;
	}
	elsif (/^\s*PROG_TYPE\s*=\s*\"*\s*([\w]+)\s*\"*\s*$/) {
		if ($1 =~ /gui/i)	{ $progGUI = 1; }
		else			{ $progGUI = 0; }
	}
	elsif (/^\s*LIB_SHARED\s*=\s*([\w]+)\s*$/) {
		if ($1 =~ /yes/i)	{ $libShared = 1; }
		else			{ $libShared = 0; }
	}
	elsif (/^\s*LIB_STATIC\s*=\s*([\w]+)\s*$/) {
		if ($1 =~ /yes/i)	{ $libStatic = 1; }
		else			{ $libStatic = 0; }
	}
	elsif (/^\s*SUBDIR\s*=\s*(.+)\s*$/) {
		@subdirs = split(/\s/, $1);
	}
	elsif (/^\s*SUBDIR\s*\+=\s*(.+)\s*$/) {
		push @subdirs, split(/\s/, $1);
	}
	elsif (/^\s*SRCS\s*=\s*(.+)\s*$/) {
		@srcs = split(/\s/, $1);
	}
	elsif (/^\s*SRCS\s*\+=\s*(.+)\s*$/) {
		push @srcs, split(/\s/, $1);
	}
	elsif (/^\s*CFLAGS\s*=\s*(.+)\s*$/) {
		@cflags = split(/\s/, $1);
	}
	elsif (/^\s*CFLAGS\s*\+=\s*(.+)\s*$/) {
		push @cflags, split(/\s/, $1);
	}
	elsif (/^\s*LIBS\s*=\s*(.+)\s*$/) {
		@libs = split(/\s/, $1);
	}
	elsif (/^\s*LIBS\s*\+=\s*(.+)\s*$/) {
		push @libs, split(/\s/, $1);
	}
}
if ($project) {
	DoProject();
}

my $packLang = 'c';
my %langs = ();
foreach my $src (@srcs) {
	if ($src =~ /\.c$/i) { $langs{'c'} = 1; }
	elsif ($src =~ /\.(cc|cpp)$/i) { $langs{'c++'} = 1; }
	elsif ($src =~ /\.cs$/i) { $langs{'c#'} = 1; }
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

if ($libName) {
	if ($libShared)	{
		DoPackage($libName.'_static', 'lib', $packLang);
		DoPackage($libName, 'dll', $packLang);
	} else {
		DoPackage($libName, 'lib', $packLang);
	}
} elsif ($progName) {
	if ($progGUI)	{ DoPackage($progName, 'winexe', $packLang); }
	else		{ DoPackage($progName, 'exe', $packLang); }
} else {
	#print STDERR "Unable to determine package kind\n";
	exit (0);
}
