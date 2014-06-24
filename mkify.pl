#!/usr/bin/perl
#
# Copyright (c) 2001-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

@Scripts = qw(
	config.guess
	mkdep
	mkconcurrent.pl
	manlinks.pl
	cmpfiles.pl
	cleanfiles.pl
	gen-declspecs.pl
	gen-includes.pl
	gen-includelinks.pl
	gen-dotdepend.pl
	install-manpages.sh);
		  
@LibtoolFiles = qw(
	Makefile
	Makefile.in
	aclocal.m4
	config.guess
	config.sub
	configure
	configure.in
	install-sh
	ltmain.sh
	README);
@LibtoolFilesM4 = qw(
	libtool.m4
	ltoptions.m4
	ltsugar.m4
	ltversion.m4
	lt~obsolete.m4);

$DATADIR = '%DATADIR%';
%copied = ();

#
# Install file as-is.
# 
sub InstallASIS
{
	my $file = shift;
	my $dst = shift;
	
	if (!defined($dst)) { $dst = 'mk/'.$file; }

	print STDERR " $file";
	unless (open(SRC, $DATADIR.'/'.$file)) {
		print STDERR "Reading $DATADIR/$file: $!\n";
		return (0);
	}
	unless (open(DST, ">$dst")) {
		print STDERR "Writing to $dst: $!\n";
		return (0);
	}
	print DST <SRC>;
	close(DST);
	close(SRC);
	return (1);
}

#
# Copy files needed by <build.www.mk>.
#
sub CopyDepsWWW
{
	if (!-e 'xsl') {
		unless (mkdir('xsl', 0755)) {
			print STDERR "xsl/: $!\n";
			return (0);
		}
	}
	InstallASIS('ml.xsl', 'xsl/ml.xsl') || return (0);
	InstallASIS('hstrip.pl') || return (0);
}

#
# Copy files needed by <build.lib.mk>.
#
sub CopyDepsLIB
{
	if (! -e 'mk/libtool' && !mkdir('mk/libtool', 0755)) {
		print STDERR "mk/libtool/: $!\n";
		return (0);
	}
	if (! -e 'mk/libtool/m4' && !mkdir('mk/libtool/m4', 0755)) {
		print STDERR "mk/libtool/m4/: $!\n";
		return (0);
	}
	foreach my $f (@LibtoolFiles) {
		InstallASIS('libtool/'.$f) || return (0);
	}
	foreach my $f (@LibtoolFilesM4) {
		InstallASIS('libtool/m4/'.$f) || return (0);
	}
	chmod(0755, 'mk/libtool/config.sub') ||
	    print STDERR "mk/libtool/config.sub: $!\n";

	return (1);
}

#
# Install a .mk file. Scan the file for include dependency and install
# these as well.
#
sub InstallMK ($)
{
	my ($file) = @_;
	my $dst = 'mk/'.$file;
	my $path = $DATADIR.'/'.$file;
	my @deps = ();
	
	print STDERR " $file";

	unless (open(SRC, $DATADIR.'/'.$file)) {
		print STDERR "$DATADIR/$file: $!\n";
		return 0;
	}
	chop(@src = <SRC>);
	close(SRC);

	unless (open(DEST, ">$dst")) {
		print STDERR "dst $dst: $!\n";
		close(SRC);
		return 0;
	}
	foreach $_ (@src) {
		print DEST $_, "\n";

		if (/^include\s*.+\/mk\/(.+)\s*$/) {
			if (!exists($copied{$1})) {
				push @deps, $1;
				$copied{$1}++;
			}
		}
	}
	close(DEST);

	foreach my $dep (@deps) {
		InstallMK($dep);
	}
	if ($file eq 'build.www.mk') {
		CopyDepsWWW() || return (0);
	}
	if ($file eq 'build.lib.mk') {
		CopyDepsLIB() || return (0);
	}
	
	$copied{$file}++;
	return 1;
}

if (!-d 'mk' && @ARGV < 1) {
	print STDERR "Usage: $0 [module-name ...]\n";
	exit(1);
}

if (!-e 'mk' || @ARGV > 0) {
	if (! -e 'mk') {
		unless (mkdir('mk', 0755)) {
			print STDERR "mk/: $!\n";
			exit (1);
		}
	}
	print STDERR "Installing in mk:";
	foreach my $type (@ARGV) {
		InstallMK("build.${type}.mk");
	}
	print STDERR ".\n";
} else {
	unless (opendir(MKDIR, 'mk')) {
		print "mk/: $!\n";
		exit(1);
	}
	print STDERR "Updating mk:";
	foreach my $f (readdir(MKDIR)) {
		if ($f =~ /^\./ || -d 'mk/'.$f) { next; }
		if ($f =~ /^(build\.[\w]+\.mk)$/) {
			InstallMK($f);
		} elsif (-e $DATADIR.'/'.$f) {
			InstallASIS($f);
		}
	}
	print STDERR ".\n";
	closedir(MKDIR);
}

print STDERR "Installing scripts:";
foreach my $script (@Scripts) {
	InstallASIS($script);
}
print STDERR ".\n";

if (!-e 'Makefile' &&
    open(MAKE, '>Makefile')) {
	if ($type eq 'prog') {
		print MAKE << 'EOF';
# Sample Makefile for a program.

# Path to parent directory of "mk".
TOP=.

# Executable output name (exact meaning is platform-dependent)
PROG=foo

#
# Source files. See the <build.prog.mk> source for a list of all
# possible source types allowed.
# 
SRCS=foo.c bar.cc baz.m

include ${TOP}/Makefile.config
include ${TOP}/mk/build.prog.mk
EOF
	} elsif ($type eq 'lib') {
		print MAKE << 'EOF';
# Sample Makefile for a library.

# Path to parent directory of "mk".
TOP=.

# Library output name (exact meaning is platform-dependent)
LIB=	foo

#
# Source files. See the <build.lib.mk> source for a list of all
# possible source types allowed.
# 
SRCS=	foo.c bar.cc baz.m

include ${TOP}/Makefile.config
include ${TOP}/mk/build.lib.mk
EOF
	} elsif ($type eq 'www') {
		print MAKE << 'EOF';
# Sample Makefile for a webpage or website.

# Path to parent directory of "mk".
TOP=.

#
# Target HTML files. The actual source files must be named foo.htm and
# bar.htm, and will be processed into a number of language and character
# set variants (ie. foo.html.en). Standard Apache-compatible variant maps
# will be generated as well.
# 
HTML=	foo.html bar.html

include ${TOP}/mk/build.www.mk
EOF
	}
	close(MAKE);
}
if (!-e 'Makefile.config' &&
    open(MAKE, '>Makefile.config')) {
	print MAKE "# File is auto-generated, do not edit\n";
	close(MAKE);
}
