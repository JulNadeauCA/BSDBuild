#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
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

my @lines = ();
my $line = '';

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
my $pkgKind = '';
my $pkgName = '';
my $pkgGUID = '';
my $pkgLinks = '';

my %modFn = ();

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

sub DoPackage
{
	if ($libName) {
		$pkgName = $libName;
		if ($libShared)	{ $pkgKind = 'dll'; }
		else		{ $pkgKind = 'lib'; }
	} elsif ($progName) {
		$pkgName = $progName;
		if ($progGUI)	{ $pkgKind = 'winexe'; }
		else		{ $pkgKind = 'exe'; }
	} else {
		#print STDERR "Unable to determine package kind\n";
		exit (0);
	}
	unless ($pkgName) {
		#print STDERR "Unable to determine package name\n";
		exit (0);
	}
	print << "EOF";
package.name = "$pkgName"
package.kind = "$pkgKind"
EOF
	if ($pkgGUID) {
		print "package.guid = \"$pkgGUID\"\n";
	}
	if ($pkgLinks) {
		print "tinsert(package.links,{\"$pkgLinks\"})\n";
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
	if (@ARGV) {
		foreach my $incl (@ARGV) {
			if (-e $incl) {
				print "dofile(\"$incl\")\n";
			} else {
				print STDERR "Ignoring include: $incl: $!\n";
			}
		}
	}
	if (@cflags) {
		my $handled = 0;
		foreach my $cflag (@cflags) {
			if ($cflag =~ /^-I\s*([\w\-\.\/]+)$/) {
				print "tinsert(package.includepaths,".
				      "{\"$1\"})\n";
				next;
			}
			if ($cflag =~ /^\${([\w\-\.]+)}$/) { $cflag = $1; }
			elsif ($cflag =~ /^\$([\w\-\.]+)$/) { $cflag = $1; }
			foreach my $fn (values %modFn) {
				if (&$fn($cflag)) {
					$handled++;
				}
			}
			if (!$handled) {
				print STDERR "Ignoring CFLAGS: $cflag\n";
			}
		}
	}
	if (@libs) {
		my $handled = 0;
		foreach my $lib (@libs) {
			if ($lib =~ /^\${([\w\-\.]+)}$/) { $lib = $1; }
			elsif ($lib =~ /^\$([\w\-\.]+)$/) { $lib = $1; }
			foreach my $fn (values %modFn) {
				if (&$fn($lib)) {
					$handled++;
				}
			}
			if (!$handled) {
				print STDERR "Ignoring LIBS: $lib\n";
			}
		}
	}
}

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
		if (exists($PREMAKE{$modname}) &&
		    defined($PREMAKE{$modname})) {
			$modFn{$modname} = $PREMAKE{$modname};
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
	elsif (/^\s*LIB_LINKS\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$pkgLinks = $1;
	}
	elsif (/^\s*PROG\s*=\s*([\w\-\.]+)\s*$/) {
		$progName = $1;
	}
	elsif (/^\s*PROG_GUID\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
		$pkgGUID = $1;
	}
	elsif (/^\s*PROG_LINKS\s*=\s*\"*\s*([\w\-\.]+)\s*\"*\s*$/) {
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
} else {
	DoPackage();
}
