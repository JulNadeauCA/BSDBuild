# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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

sub TestPthreadsStd
{
	print Define('PTHREADS_CFLAGS', '');
	print Define('PTHREADS_LIBS', '-pthread');
	
	TryLibCompile 'HAVE_PTHREADS',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF';
#include <pthread.h>
#include <signal.h>

int
main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_t thread;
	pthread_cond_t cond;
	pthread_key_t key;

	pthread_mutex_init(&mutex, NULL);
	pthread_mutex_lock(&mutex);
	pthread_mutex_unlock(&mutex);
	pthread_mutex_destroy(&mutex);
	return (0);
}
EOF
	print
		Cond('"${HAVE_PTHREADS}" = "yes"',
		MKSave('PTHREADS_CFLAGS') .
		MKSave('PTHREADS_LIBS') .
		HDefineStr('PTHREADS_CFLAGS') .
		HDefineStr('PTHREADS_LIBS') ,
		HUndef('PTHREADS_CFLAGS') .
		HUndef('PTHREADS_LIBS'));
	return (0);
}

sub TestPthreadMutexRecursive
{
	print NEcho 'checking for PTHREAD_MUTEX_RECURSIVE...';
	TryLibCompile 'HAVE_PTHREAD_MUTEX_RECURSIVE',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF';
#include <pthread.h>
#include <signal.h>

int
main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;

	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	print
		Cond('"${HAVE_PTHREAD_MUTEX_RECURSIVE}" = "yes"',
		HDefineBool('HAVE_PTHREAD_MUTEX_RECURSIVE') .
		HDefineBool('HAVE_PTHREAD_MUTEX_RECURSIVE') ,
		HUndef('HAVE_PTHREAD_MUTEX_RECURSIVE') .
		HUndef('HAVE_PTHREAD_MUTEX_RECURSIVE'));
	
	print NEcho 'checking for PTHREAD_MUTEX_RECURSIVE_NP...';
	TryLibCompile 'HAVE_PTHREAD_MUTEX_RECURSIVE_NP',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF';
#include <pthread.h>
#include <signal.h>

int
main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;

	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE_NP);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	print
		Cond('"${HAVE_PTHREAD_MUTEX_RECURSIVE_NP}" = "yes"',
		HDefineBool('HAVE_PTHREAD_MUTEX_RECURSIVE_NP') .
		HDefineBool('HAVE_PTHREAD_MUTEX_RECURSIVE_NP') ,
		HUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP') .
		HUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP'));
	return (0);
}

sub TestPthreadsXOpenExt
{
	print NEcho 'checking for the X/Open Threads Extension...';
	TryLibCompile 'HAVE_PTHREADS_XOPEN',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF';
#define _XOPEN_SOURCE 500
#include <pthread.h>
#include <signal.h>
#undef _XOPEN_SOURCE

int
main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;

	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	print
		Cond('"${HAVE_PTHREADS_XOPEN}" = "yes"',
		HDefineBool('HAVE_PTHREADS_XOPEN') .
		HDefineBool('HAVE_PTHREADS_XOPEN') ,
		HUndef('HAVE_PTHREADS_XOPEN') .
		HUndef('HAVE_PTHREADS_XOPEN'));
	return (0);
}

sub TestPthreads
{
	TestPthreadsStd();
	TestPthreadsXOpenExt();
	TestPthreadMutexRecursive();
	return (0);
}

BEGIN
{
	$TESTS{'pthreads'} = \&TestPthreads;
	$DESCR{'pthreads'} = 'POSIX threads';
}

;1