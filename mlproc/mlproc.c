/*
 * Copyright (c) 2016 Julien Nadeau <vedge@hypertriton.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Process <ml lang="xx">Text</ml> and $_("Text") elements in a document.
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <libintl.h>

#include "config/have_gettext.h"

static int curLine = 0;
static char curError[64];
static char *lang = "en";
static char *localedir = NULL;
static char *domainname = NULL;

static void
printusage(void)
{
	fprintf(stderr, "Usage: mlproc [-l lang] [-o outfile] "
	                "[-L localedir] [-D textdomain] [infile]\n");
}

static int
processInput(const char *data, size_t size, FILE *f)
{
	const char *c, *cEnd;
	int inCurLang=0, inOtherLang=0;
	char *cText, *d;

	for (c=data; *c != '\0';) {
		if (*c == '<') {
			/*
			 * Process <ml lang="xx">Text</ml> blocks.
			 * Nesting is not permitted.
			 */
			if (inCurLang > 0) {
				if (strncmp(&c[1],"ml lang=\"",9)==0) {
					goto fail_nested;
				}
				if (strncmp(&c[1],"/ml>",4)==0) {
					if (--inCurLang < 0) { goto fail_closetag; }
					c += 5;
					continue;
				}
			} else {
				if (inOtherLang > 0) {
					if (strncmp(&c[1],"/ml>\n",5)==0) {
						if (--inOtherLang < 0) {
							goto fail_closetag;
						}
						c += 6;
						continue;
					} else if (strncmp(&c[1],"/ml>",4)==0) {
						if (--inOtherLang < 0) {
							goto fail_closetag;
						}
						c += 5;
						continue;
					}
				} else {
					if (strncmp(&c[1],"ml lang=\"",9)==0) {
						if (strncmp(&c[10],lang,2)==0) {
							if (++inCurLang > 1)
								goto fail_nested;
						} else {
							if (++inOtherLang > 1)
								goto fail_nested;
						}
						if (c[14] == '\n') {
							c += 15;
						} else {
							c += 14;
						}
						continue;
					}
				}
			}
		} else if (*c=='$' && c[1]=='_' && c[2] == '(') {
			/*
			 * Process instances of "$_(Text)" via gettext.
			 * Escape codes \( and \) may be used.
			 */
			for (cEnd = &c[3]; *cEnd != '\0'; cEnd++) {
				if (cEnd[0] != '\\' && cEnd[1] == ')') {
					cEnd++;
					break;
				}
			}
			if (*cEnd == '\0') {
				goto fail_unterm;
			}
			if ((cText = malloc((cEnd - &c[3])+1)) == NULL) {
				goto fail_mem;
			}
			for (c=&c[3], d=&cText[0]; c != cEnd; c++, d++) {
				if (c[0] == '\\') {
					if (c[1]=='(') { *d='('; c++; }
					else if (c[1]==')') { *d=')'; c++; }
					else { *d = *c; }
				} else {
					*d = *c;
				}
			}
			*d = '\0';
#ifdef HAVE_GETTEXT
			fputs(dgettext(domainname,cText), f);
#else
			fputs(cText, f);
#endif
			free(cText);
			c = &cEnd[1];
			continue;
		} else if (*c == '\n') {
			curLine++;
		}
		if (!inOtherLang) {
			fputc(*c, f);
		}
		c++;
	}
	return (0);
fail_nested:
	strlcpy(curError, "Nested <ml> tags are not allowed", sizeof(curError));
	return (-1);
fail_closetag:
	strlcpy(curError, "Unexpected </ml> tag", sizeof(curError));
	return (-1);
fail_unterm:
	strlcpy(curError, "Unterminated $_() sequence", sizeof(curError));
	return (-1);
fail_mem:
	strlcpy(curError, "Out of memory", sizeof(curError));
	return (-1);
}

int
main(int argc, char *argv[])
{
	const char *outfile = NULL, *infile;
	extern char *optarg;
	extern int optind;
	int c, cnt;
	FILE *f, *fin;
	char *indata;
	size_t rv, i, size, nRead;

	curError[0] = '\0';

	while ((c = getopt(argc, argv, "?o:l:L:D:")) != -1) {
		switch (c) {
		case 'o':
			outfile = optarg;
			break;
		case 'l':
			lang = optarg;
			break;
		case 'L':
			localedir = optarg;
			break;
		case 'D':
			domainname = optarg;
			break;
		case '?':
		case 'h':
		default:
			printusage();
			return (1);
		}
	}
	if (optind == argc) {
		printusage();
		return (1);
	}
	infile = argv[optind];
	if (!(fin = (strcmp(infile,"-")==0) ? stdin : fopen(infile, "r"))) {
		fprintf(stderr, "%s: %s\n", infile, strerror(errno));
		return (1);
	}
	if (!(f = (outfile==NULL) ? stdout : fopen(outfile, "w"))) {
		fprintf(stderr, "%s: %s\n", outfile, strerror(errno));
		fclose(fin);
		return (1);
	}
	
	if (fseek(fin, 0, SEEK_END) != 0) {
		fprintf(stderr, "SEEK_END: %s\n", strerror(errno));
		goto fail;
	}
	size = ftell(fin);
	if (fseek(fin, 0, SEEK_SET) != 0) {
		fprintf(stderr, "SEEK_SET: %s\n", strerror(errno));
		goto fail;
	}

	if ((indata = malloc(size+14+1)) == NULL) {
		fprintf(stderr, "%s: Out of memory\n", infile);
		goto fail;
	}
	for (nRead = 0; nRead < size;) {
		if ((rv = fread(indata, 1, size, fin)) == 0) {
			break;
		} else if (rv == -1) {
			fprintf(stderr, "%s: read error\n", infile);
			goto fail;
		} else {
			nRead += rv;
		}
	}
	indata[size] = '\0';

#ifdef HAVE_GETTEXT
	if (localedir && domainname) {
		setlocale(LC_ALL, "");
		setenv("LANG", lang, 1);
		setenv("LANGUAGE", lang, 1);
		bindtextdomain(domainname, localedir);
		bind_textdomain_codeset(domainname, "UTF-8");
		textdomain(domainname);
	}
#endif
	if (processInput(indata, size, f) != 0) {
		fprintf(stderr, "%s:%d: %s\n", infile, curLine, curError);
		free(indata);
		goto fail;
	}
	fclose(f);
	fclose(fin);
	free(indata);
	return (0);
fail:
	fclose(f);
	fclose(fin);
	return (1);
}

