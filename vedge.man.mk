# $Id$

TYPE=	    man

NROFF?=	    nroff -Tascii
TBL?=	    tbl

.SUFFIXES:  .1 .2 .3 .4 .5 .6 .7 .8 .9 .cat1 .cat2 .cat3 .cat4 .cat5 .cat6 .cat7 .cat8 .cat9
#	    .1tbl .2tbl .3tbl .4tbl .5tbl .6tbl .7tbl .8tbl .9tbl \
#	   

.9.cat9 .8.cat8 .7.cat7 .6.cat6 .5.cat5 .4.cat4 .3.cat3 .2.cat2 .cat1.1:
	$(NROFF) -mandoc $< > $@ || (rm -f $@; false)

