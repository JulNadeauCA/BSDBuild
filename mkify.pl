#!/usr/bin/perl
#
# $Csoft: mkify.pl,v 1.15 2003/06/25 02:48:27 vedge Exp $
#
# Copyright (c) 2001, 2002, 2003 CubeSoft Communications, Inc.
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

sub MKCopy;

sub MKCopy
{
	my ($src, $dir) = @_;
	my $destmk = join('/', 'mk', $src);
	my $srcmk = join('/', $dir, $src);
	my @deps = ();

	unless (-f $srcmk) {
		print STDERR "src $srcmk: $!\n";
		return 0;
	}
	unless (open(SRC, $srcmk)) {
		print STDERR "src $srcmk: $!\n";
		return 0;
	}
	chop(@src = <SRC>);
	close(SRC);

	unless (open(DEST, ">$destmk")) {
		print STDERR "dst $destmk: $!\n";
		close(SRC);
		return 0;
	}
	foreach $_ (@src) {
		print DEST $_, "\n";

		if (/^include .+\/mk\/(.+)$/) {
			print "$src: depends on $1\n";
			push @deps, $1;
		}
	}
	close(DEST);

	foreach my $dep (@deps) {
		MKCopy($dep, $dir);
	}

	return 1;
}

BEGIN
{
	my $dir = '%PREFIX%/share/csoft-mk';
	my $mk = './mk';

	if (! -d $mk && !mkdir($mk)) {
		print STDERR "mkdir $mk: $!\n";
		exit (1);
	}

	if (opendir(MKDIR, $mk)) {
		foreach my $f (readdir(MKDIR)) {
			next unless -f "$mk/$f";
			MKCopy($f, $dir);
		}
		closedir(MKDIR);
	} else {
		print "opendir $mk: $!\n";
		exit (1);
	}

	foreach my $f (@ARGV) {
		$f = join('.', 'csoft', $f, 'mk');
		my $dest = join('/', $mk, $f);

		MKCopy($f, $dir);
		if ($f eq 'www') {
			MKCopy('hstrip.pl', $dir);
		}
	}
	MKCopy('mkdep', $dir);
	MKCopy('mkconcurrent.pl', $dir);
}
