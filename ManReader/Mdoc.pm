#!/usr/bin/perl
#
# Copyright (c) 2009-2020 Julien Nadeau Carriere <vedge@hypertriton.com>
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
# ManReader::Mdoc - Output a manual page in mandoc format.
#
package ManReader::Mdoc;

use strict;

our ($Date, $Title, $Section, $Desc, $Name);
my $name_flag = 0;
my $list_enum = 0;		# In Bl -enum
my $list_tag = 0;		# In Bl -tag
my $list_tag_item = 0;		# In Bl It
my $shflag = 0;			# In section
my $shline = 0;			# Line in current section
my $bdflag = 0;			# In Bd
my $protoflag = 0;		# In function prototype section
my $bibflag = 0;		# In bibliography
my $prevCmd = '';		# Command on previous line
my $nextCmd = '';		# Command on next line.
my $category = '';		# For wikitext

#
# Generic preprocessing stage.
#
sub Preprocess ($)
{
	if (/^\.\\\"/ || /^\.Os$/ || /^\.ds vT/ || /\.ds oS/) {
		return (undef);
	}
	if (/^\.Dd (.+)$/) {
		$Date = $1;
		return (undef);
	}
	if (/^\.Dt (\w+) (\d+)$/) {
		$Title = $1;
		$Section = $2;
		return (undef);
	}
	if (/^\.Sh NAME/) {
		$name_flag = 1;
		return (undef);
	} elsif (/^\.Sh/) {
		$name_flag = 0;
	}
	if ($name_flag) {
		if (/^\.Nm (\w+)$/) {
			$Name = $1;
			return (undef);
		}
		if (/^\.Nd (.+)$/) {
			$Desc = $1;
			$Desc =~ s/^([a-z])/\u$1/;
			return (undef);
		}
	}
	return ($_);
}

sub Trail
{
	return (join('', split(' ', shift)));
}

sub TrailSep
{
	my @rlist = ();
	my @trail = ();

	foreach my $it (@_) {
		foreach my $word (split(' ', $it)) {
			if ($word =~ /^[[:punct:]]$/) {
				push @trail, $word;
			} else {
				push @rlist, $word; 
			}
		}
	}
	return (join(' ', @rlist), join('', @trail));
}

sub ConvNBSP ($)
{
	my $s = shift;
	my $inTag = 0;
	my @r = ();
	
	foreach my $ch (split('', $s)) {
		if ($ch eq '<') { $inTag++; }
		elsif ($ch eq '>') { $inTag = 0; }

		if (!$inTag && ($ch eq ' ' || $ch eq "\t")) {
			push @r, ('&','n','b','s','p',';');
		} else {
			push @r, $ch;
		}
	}
	return join('', @r);
}

#
# Parse a mandoc element to HTML output.
#
sub ParseElementToHTML
{
	$_ = shift;
	my @item = ();

	if (/^Pp$/) {
		if ($shline == 0 && $protoflag == 0) {
			# Skip Pp on first line of any section.
			next;
		}
		if ($prevCmd eq 'El' || $prevCmd eq 'Ed') {
			# Skip Pp right after El or Ed.
			return ('<br>');
		}
		if ($nextCmd =~ /^\.Bl/) {
			return ('<br>');
		}
		if ($protoflag) {
			return ('<br>');
		}
		return '<br><br>';
	} elsif (/^Ft (.+)$/) {
		@item = TrailSep($1);
		my $type = $item[0];
		$type =~ s/"(.+)"/$1/;
		return "<font class=ft><b>".$type.'</b></font>'.$item[1].' ';
	} elsif (/^Fn ([\w\s\-\[\]()\*\&\.,:;]+)$/) {
		@item = TrailSep($1);
		return '<font class=fnName>'.$item[0].'()</font>'.$item[1].' ';
	} elsif (/^Fn ([\w\s\-\."\*\&,;:\[\]\(\)]+)$/) {
		my $func = $1;
		my $rv = '';

		if ($protoflag && /^Fn ([\w\-\.\*\&\[\]]+)/) {
			$rv = qq{<a class=fnName name="$1"></a>};
		}
		if ($func =~ /\s"/) {
			#$func =~ s/\s/&nbsp;/g;
			$func =~ s/"(.+)"/(<font class=fnArgs>$1<\/font>)/g;
			$func =~ s/" "/, /g;
			$rv .= '<font class=fnSpec>'.$func.'</font>'.Trail($2).
			       '<br>';
		} else {
			$rv .= '<font class=fnSpec>'.$func.'()</font>'.
			       Trail($2).' ';
		}
		return ($rv);
	} elsif (/^Fa (.+)$/) {
		@item = TrailSep($1);
		return '<var class=fa>'.$item[0].'</var>'.$item[1].' ';
	} elsif (/^nr nS 1$/) {
		$protoflag = 1;
		return '<table border=0 cellspacing=0 style="margin-left:16px'.
		       'margin-bottom:0; border:solid;border-width:1px;'.
		       'border-color:#c0c0c0; padding-left:10px; '.
		       'padding-right:10px"><tr><td><br>';
	} elsif (/^nr nS 0$/) {
		$protoflag = 0;
		return '</td></tr></table><br>';
	} elsif (/^Bd (.+)$/) {
		$bdflag = 1;
		return '<pre style="margin-bottom:0; margin-top:5px; margin-left:0.125in; font-family:courier; font-weight:bold; font-size:small">';
	} elsif (/^Ed$/) {
		$bdflag = 0;
		return '</pre>';
	} elsif (/^Fd (.+)$/) {
		@item = TrailSep($1);
		return '<pre>'.$item[0].'</pre>'.$item[1].' ';
	} elsif (/^(Sq|Dq) (.+)$/) {
		if ($2 =~ /^(.){1}$/) {
			return ' <font class=pref>&quot; '.$1.' &quot; </font>';
		} elsif ($2 =~ /^(.) (.)$/) {
			return ' <font class=pref>&quot; '.$1.' &quot;</font>'.
			       $2.' ';
		} else {
			@item = TrailSep($2);
			return ' <font class=pref>'.
			       ParseElementToHTML($item[0]).'</font>'.
			       $item[1].' ';
		}
	} elsif (/^Dv (.+)$/) {
		@item = TrailSep($1);
		return '<font class=dv>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Va (.+)$/) {
		@item = TrailSep($1);
		return '<var class=va>'.ParseElementToHTML($item[0]).'</var>'.
		       $item[1].' ';
	} elsif (/^Em (.+)$/) {
		@item = TrailSep($1);
		return '<font class=em>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Pa (.+)$/) {
		@item = TrailSep($1);
		return '<font class=pa>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Xr ([\w\.\-\+]+) (\d)( (.+))*$/) {
		my $man = $1;
		my $sec = $2;
		my $trail = Trail($4);
		return qq{<a class=xr href="$main::SCRIPTNAME?man=$man.$sec$main::SCRIPTARGS">$man($sec)</a>$trail };
	} elsif (/^Xr ([\w\.\-\+\(\[]) ([\w\-]+) (\d)( (.+))*$/) {
		my $prepend = $1;
		my $man = $2;
		my $sec = $3;
		my $append = Trail($4);
		return qq{$prepend<a class=xr href="$main::SCRIPTNAME?man=$man.$sec$main::SCRIPTARGS">$man($sec)</a>$append };
	} elsif (/^Xr ([\w\.\-\+]+)\s*( (.+))*$/) {
		my $man = $1;
		my $trail = Trail($3);
		return qq{<a class=xr href="$main::SCRIPTNAME?man=$man.7$main::SCRIPTARGS">$man</a>$trail };
	} elsif (/^Nm( (.){0,2})*$/) {
		return '<font class=nm>'.$Name.'</font>'.Trail($1).' ';
	} elsif (/^Rs$/) {
		$bibflag = 1;
		return ('<ul>');
	} elsif (/^%T (.+)$/) {
		return ('<li><i>'.$1.'</i><br>');
	} elsif (/^%A "(.+)"$/) {
		return ('<i>'.$1.'</i>, ');
	} elsif (/^%D "(.+)"$/) {
		return ($1);
	} elsif (/^Re$/) {
		$bibflag = 0;
		return ('</ul>');
	} elsif (/^(Bx) (\S+) (.+)$/) {		return ("BSD".Trail($3));
	} elsif (/^(Bx) (.+)$/) {		return ("BSD ");
	} elsif (/^(Fx) (\S+) (.+)$/) {		return ("<a class=ext href='https://freebsd.org/>FreeBSD</a>".Trail($3));
	} elsif (/^(Fx) (.+)$/) {		return ("<a class=ext href='https://freebsd.org/>FreeBSD</a> ");
	} elsif (/^(Nx) (\S+) (.+)$/) {		return ("<a class=ext href='https://netbsd.org/>NetBSD</a>".Trail($3));
	} elsif (/^(Nx) (.+)$/) {		return ("<a class=ext href='https://netbsd.org/>NetBSD</a> ");
	} elsif (/^(Ox) (\S+) (.+)$/) {		return ("<a class=ext href='https://openbsd.org/>OpenBSD</a>".Trail($3));
	} elsif (/^(Ox) (.+)$/) {		return ("<a class=ext href='https://openbsd.org/>OpenBSD</a> ");
	} elsif (/^(Bsx) (\S+) (.+)$/) {	return ("BSDI BSD/OS".Trail($3));
	} elsif (/^(Bsx) (.+)$/) {		return ("BSDI BSD/OS ");
	} elsif (/^(Ux) (\S+) (.+)$/) {		return ("UNIX".Trail($3));
	} elsif (/^(Ux) (.+)$/) {		return ("UNIX ");
	} elsif (/^(At) (\S+) (.+)$/) {		return ("AT&T UNIX".Trail($3));
	} elsif (/^(At) (.+)$/) {		return ("AT&T UNIX ");
	} elsif (/^(Fl) (\S+) (.+)$/) {		return ("<font class=pref>-$2</font>".Trail($3));
	} elsif (/^(Fl) (.+)$/) {		return ("<font class=pref>-$2</font> ");
	} elsif (/^(Ql) (\S+) (.+)$/) {		return ("<font class=pref>&quot;$2&quot;</font>".Trail($3));
	} elsif (/^(Ql) (.+)$/) {		return ("<font class=pref>&quot;$2&quot;</font> ");
	} elsif (/^(Tn|Ev) (\S+) (.+)$/) {	return ("<font class=pref>$2</font>".Trail($3));
	} elsif (/^(Tn|Ev) (.+)$/) {		return ("<font class=pref>$2</font> ");
	} elsif (/^(Ar) (\S+) (.+)$/) {		return ("<b>$2</b>".Trail($3));
	} elsif (/^(Ar) (.+)$/) {		return ("<b>$2</b> ");
	} else {
		return ($_);
	}
}

#
# Parse a mandoc element to wikitext output.
#
sub ParseElementToWikitext
{
	$_ = shift;
	my @item = ();

	if (/^Pp$/) {
		if ($shline == 0 && $protoflag == 0) {
			# Skip Pp on first line of any section.
			next;
		}
		if ($prevCmd eq 'El' || $prevCmd eq 'Ed') {
			# Skip Pp right after El or Ed.
			return ('<br>');
		}
		if ($nextCmd =~ /^\.Bl/) {
			return ('<br>');
		}
		if ($protoflag) {
			return ('<br>');
		}
		return '<br><br>';
	} elsif (/^Ft (.+)$/) {
		@item = TrailSep($1);
		my $type = $item[0];
		$type =~ s/"(.+)"/$1/;
		return "<font class=ft><b>".$type.'</b></font>'.$item[1].' ';
	} elsif (/^Fn ([\w\s\-\[\]()\*\&\.,:;]+)$/) {
		@item = TrailSep($1);
		return '<font class=fnName>'.$item[0].'()</font>'.$item[1].' ';
	} elsif (/^Fn ([\w\s\-\."\*\&,;:\[\]\(\)]+)$/) {
		my $func = $1;
		my $rv = '';

		if ($protoflag && /^Fn ([\w\-\.\*\&\[\]]+)/) {
			$rv = "[[$category$1|$1]]";
		}
		if ($func =~ /\s"/) {
			#$func =~ s/\s/&nbsp;/g;
			$func =~ s/"(.+)"/(<font class=fnArgs>$1<\/font>)/g;
			$func =~ s/" "/, /g;
			$rv .= '<font class=fnSpec>'.$func.'</font>'.Trail($2).
			       '<br>';
		} else {
			$rv .= '<font class=fnSpec>'.$func.'()</font>'.
			       Trail($2).' ';
		}
		return ($rv);
	} elsif (/^Fa (.+)$/) {
		@item = TrailSep($1);
		return '<var class=fa>'.$item[0].'</var>'.$item[1].' ';
	} elsif (/^nr nS 1$/) {
		$protoflag = 1;
		return '<table border=0 cellspacing=0 style="margin-left:16px'.
		       'margin-bottom:0; border:solid;border-width:1px;'.
		       'border-color:#c0c0c0; padding-left:10px; '.
		       'padding-right:10px"><tr><td><br>';
	} elsif (/^nr nS 0$/) {
		$protoflag = 0;
		return '</td></tr></table><br>';
	} elsif (/^Bd (.+)$/) {
		$bdflag = 1;
		return '<pre style="margin-bottom:0; margin-top:5px; margin-left:0.125in; font-family:courier; font-weight:bold; font-size:small">';
	} elsif (/^Ed$/) {
		$bdflag = 0;
		return '</pre>';
	} elsif (/^Fd (.+)$/) {
		@item = TrailSep($1);
		return '<pre>'.$item[0].'</pre>'.$item[1].' ';
	} elsif (/^(Sq|Dq) (.+)$/) {
		if ($2 =~ /^(.){1}$/) {
			return ' <font class=pref>&quot; '.$1.' &quot; </font>';
		} elsif ($2 =~ /^(.) (.)$/) {
			return ' <font class=pref>&quot; '.$1.' &quot;</font>'.
			       $2.' ';
		} else {
			@item = TrailSep($2);
			return ' <font class=pref>'.
			       ParseElementToHTML($item[0]).'</font>'.
			       $item[1].' ';
		}
	} elsif (/^Dv (.+)$/) {
		@item = TrailSep($1);
		return '<font class=dv>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Va (.+)$/) {
		@item = TrailSep($1);
		return '<var class=va>'.ParseElementToHTML($item[0]).'</var>'.
		       $item[1].' ';
	} elsif (/^Em (.+)$/) {
		@item = TrailSep($1);
		return '<font class=em>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Pa (.+)$/) {
		@item = TrailSep($1);
		return '<font class=pa>'.ParseElementToHTML($item[0]).'</font>'.
		       $item[1].' ';
	} elsif (/^Xr ([\w\.\-\+]+) (\d)( (.+))*$/) {
		return "[[$category$1|$1]]".Trail($4);
	} elsif (/^Xr ([\w\.\-\+\(\[]) ([\w\-]+) (\d)( (.+))*$/) {
		return $1. "[[$category$2|$2]]" . Trail($4);
	} elsif (/^Xr ([\w\.\-\+]+)\s*( (.+))*$/) {
		return "[[$category$1|$1]]".Trail($3);
	} elsif (/^Nm( (.){0,2})*$/) {
		return '<font class=nm>'.$Name.'</font>'.Trail($1).' ';
	} elsif (/^Rs$/) {
		$bibflag = 1;
		return ('<ul>');
	} elsif (/^%T (.+)$/) {
		return ('<li><i>'.$1.'</i><br>');
	} elsif (/^%A "(.+)"$/) {
		return ('<i>'.$1.'</i>, ');
	} elsif (/^%D "(.+)"$/) {
		return ($1);
	} elsif (/^Re$/) {
		$bibflag = 0;
		return ('</ul>');
	} elsif (/^(Bx) (\S+) (.+)$/) {		return ("BSD".Trail($3));
	} elsif (/^(Bx) (.+)$/) {		return ("BSD ");
	} elsif (/^(Fx) (\S+) (.+)$/) {		return ("[https://freebsd.org/ FreeBSD]".Trail($3));
	} elsif (/^(Fx) (.+)$/) {		return ("[https://freebsd.org/ FreeBSD] ");
	} elsif (/^(Nx) (\S+) (.+)$/) {		return ("[https://netbsd.org/ NetBSD]".Trail($3));
	} elsif (/^(Nx) (.+)$/) {		return ("[https://netbsd.org/ NetBSD] ");
	} elsif (/^(Ox) (\S+) (.+)$/) {		return ("[https://openbsd.org/ OpenBSD]".Trail($3));
	} elsif (/^(Ox) (.+)$/) {		return ("[https://openbsd.org/ OpenBSD] ");
	} elsif (/^(Bsx) (\S+) (.+)$/) {	return ("BSDI BSD/OS".Trail($3));
	} elsif (/^(Bsx) (.+)$/) {		return ("BSDI BSD/OS ");
	} elsif (/^(Ux) (\S+) (.+)$/) {		return ("UNIX".Trail($3));
	} elsif (/^(Ux) (.+)$/) {		return ("UNIX ");
	} elsif (/^(At) (\S+) (.+)$/) {		return ("AT&T UNIX".Trail($3));
	} elsif (/^(At) (.+)$/) {		return ("AT&T UNIX ");
	} elsif (/^(Fl) (\S+) (.+)$/) {		return ("<font class=pref>-$2</font>".Trail($3));
	} elsif (/^(Fl) (.+)$/) {		return ("<font class=pref>-$2</font> ");
	} elsif (/^(Ql) (\S+) (.+)$/) {		return ("<font class=pref>&quot;$2&quot;</font>".Trail($3));
	} elsif (/^(Ql) (.+)$/) {		return ("<font class=pref>&quot;$2&quot;</font> ");
	} elsif (/^(Tn|Ev) (\S+) (.+)$/) {	return ("<font class=pref>$2</font>".Trail($3));
	} elsif (/^(Tn|Ev) (.+)$/) {		return ("<font class=pref>$2</font> ");
	} elsif (/^(Ar) (\S+) (.+)$/) {		return ("<b>$2</b>".Trail($3));
	} elsif (/^(Ar) (.+)$/) {		return ("<b>$2</b> ");
	} else {
		return ($_);
	}
}

#
# Generate HTML source from manual source.
#
sub ParseToHTML
{
	my $nLine = 0;
	foreach my $line (@_) {
		$line =~ s/</&lt;/g;
		$line =~ s/>/&gt;/g;
		$line =~ s/R\^(\w+)\b/R<sup>$1<\/sup>/g;
		$line =~ s/(http:\/\/[\w.-\/]+)/<a href="$1">$1<\/a>/g;
		if ($line =~ /Agar\s+\d{1,2}\.\d{1,2}\.\d{1,2}/) {
			$line =~ s/Agar\s+(\d{1,2}\.\d{1,2}\.\d{1,2})\b/
		           <a href="https:\/\/stable.hypertriton.com\/agar\/agar-$1.tar.gz">Agar $1<\/a>/gx;
		} else {
			$line =~ s/Agar\s+(\d{1,2}\.\d{1,2})\b/
		           <a href="https:\/\/stable.hypertriton.com\/agar\/agar-$1.tar.gz">Agar $1<\/a>/gx;
		}
		if ($shflag) {
			$shline++;
		}
		$nextCmd = $_[$nLine+1];
		$nLine++;
		if ($line =~ /^\.(.+)$/) {
			my $cmd = $1;
			if ($cmd =~ /^Sh (.+)$/) {
				if ($shflag) {
					print '</td></tr></table>';
				}
				my $sname = $1;
				my $aname = $1;
				$aname =~ tr/ /_/;
				print << "EOF";
<a name="$aname"></a>
<hr>
<h1 class=mansection>$sname</h1>
<table class=mdocSection>
<tr>
  <td class=mdocSection>
EOF
				$shflag++;
				$shline = 0;
			} elsif ($cmd =~ /^Bl (.+)$/) {
				my $opts = $1;
				if ($opts =~ /-tag/) {
					$list_tag = 1;
					print '<table border=0 cellspacing=0 '.
					      'cellpadding=0 class=mdocTagTbl>';
				} else {
					$list_tag = 0;
					if ($opts =~ /-enum/) {
						$list_enum = 1;
						print '<ol class=mdocEnum>';
					} else {
						print '<ul class=mdocEnum>';
					}
				}
				$list_tag_item = 0;
			} elsif ($cmd =~ /^It\s*(.*)$/) {
				my $item = ParseElementToHTML($1);

				if ($list_tag) {
					#$item = ConvNBSP($item);
					print '<tr><td class=mdocTagListItem>',
					      $item,
					      '</td><td class=mdocTagListItem>';
					$list_tag_item = 1;
				} else {
					print '<li class=mdocListItem>', $item;
				}
			} elsif ($cmd =~ /^El$/) {
				if ($list_tag) {		# In .Bl -tag
					if ($list_tag_item) {	# In .It
						print '</td></tr>';
					}
					print '</table>';
				} else {
					if ($list_enum) {
						print '</ol>';
					} else {
						print '</ul>';
					}
				}
			} else {
				print ParseElementToHTML($cmd);
			}
			$prevCmd = $cmd;
			next;
		} else {
			print $line, "\n";
		}
	}
	if ($shflag) {
		print '</table>';
	}
}

#
# Generate wikitext from manual source.
#
sub ParseToWikitext
{
	$category = shift(@_);

	my $nLine = 0;
	foreach my $line (@_) {
		$line =~ s/</&lt;/g;
		$line =~ s/>/&gt;/g;
		$line =~ s/R\^(\w+)\b/R<sup>$1<\/sup>/g;
		#$line =~ s/(http:\/\/[\w.-\/]+)/<a href="$1">$1<\/a>/g;
		if ($line =~ /Agar\s+\d{1,2}\.\d{1,2}\.\d{1,2}/) {
			$line =~ s/Agar\s+(\d{1,2}\.\d{1,2}\.\d{1,2})\b/[[Agar-$1]]/gx;
		} else {
			$line =~ s/Agar\s+(\d{1,2}\.\d{1,2})\b/[[Agar-$1]]/gx;
		}
		if ($shflag) {
			$shline++;
		}
		$nextCmd = $_[$nLine+1];
		$nLine++;
		if ($line =~ /^\.(.+)$/) {
			my $cmd = $1;
			if ($cmd =~ /^Sh (.+)$/) {
				print "==$1==\n";
				$shflag++;
				$shline = 0;
			} elsif ($cmd =~ /^Bl (.+)$/) {
				my $opts = $1;
				if ($opts =~ /-tag/) {
					$list_tag = 1;
					print '<table border=0 cellspacing=0 '.
					      'cellpadding=0 class=mdocTagTbl>';
				} else {
					$list_tag = 0;
					if ($opts =~ /-enum/) {
						$list_enum = 1;
					}
				}
				$list_tag_item = 0;
			} elsif ($cmd =~ /^It\s*(.*)$/) {
				my $item = ParseElementToWikitext($1);

				if ($list_tag) {
					#$item = ConvNBSP($item);
					print '<tr><td class=mdocTagListItem>',
					      $item,
					      '</td><td class=mdocTagListItem>';
					$list_tag_item = 1;
				} elsif ($list_enum) {
					print '# '.$item."\n";
				} else {
					print '* '.$item."\n";
				}
			} elsif ($cmd =~ /^El$/) {
				if ($list_tag) {		# In .Bl -tag
					if ($list_tag_item) {	# In .It
						print '</td></tr>';
					}
					print '</table>';
				}
			} else {
				print ParseElementToWikitext($cmd);
			}
			$prevCmd = $cmd;
			next;
		} else {
			print $line, "\n";
		}
	}
	if ($shflag) {
		print "\n"
	}
}

;1
