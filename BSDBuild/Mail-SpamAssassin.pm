# vim:ts=4
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
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

sub Test
{
	MkRunPerl('HAVE_SPAMASSASSIN', '', << 'EOF');
use strict;
use Fcntl;
use Sys::Hostname;
use Mail::SpamAssassin;

our $Assassin = Mail::SpamAssassin->new({
    'home_dir_for_helpers' => '.',
    'local_tests_only' => 1});

require Mail::SpamAssassin::DBBasedAddrList;
our $AddrListFactory = Mail::SpamAssassin::DBBasedAddrList->new();
$Assassin->set_persistent_address_list_factory($AddrListFactory);

$AddrListFactory->finish();
$Assassin->finish();
EOF
	return (0);
}

BEGIN
{
	$DESCR{'Mail-SpamAssassin'} = 'the Mail::SpamAssassin module';
	$URL{'Mail-SpamAssassin'} = 'http://spamassassin.org';

	$TESTS{'Mail-SpamAssassin'} = \&Test;
	$DEPS{'Mail-SpamAssassin'} = 'perl';
}

;1
