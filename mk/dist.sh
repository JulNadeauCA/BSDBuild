#!/bin/sh
# Public domain
#
# Release script for BSDBuild.
#

PROJ=bsdbuild
VER=${VERSION}
REL=${RELEASE}
DISTNAME=${PROJ}-${VER}
RHOST=resin

if [ "$1" != "" ]; then
	PHASE="$1"
else
	PHASE=stable
fi
REMOTEDIR=www/${PHASE}.hypertriton.com/${PROJ}
CHANGELOGDIR=www/${PROJ}

cd ..

echo "*"
echo "* Project: ${PROJ}"
echo "* State: ${PHASE}"
echo "* Version: ${VER}"
echo "* Release: ${REL}"
echo "*"

#
# Prepare Source TAR.GZ.
#
echo "Building tar.gz"
if [ -e "${DISTNAME}" ]; then
	echo "* Existing directory: ${DISTNAME}; remove first"
	exit 1
fi
cp -fRp ${PROJ} ${DISTNAME}
rm -fR `find ${DISTNAME} \( -name .svn -or -name \*~ -or -name .\*.swp \)`

# TAR: Prepare standard text files.
(cd ${DISTNAME} &&
 cp -f ChangeLogs/Release-${VER}.txt RELEASE-${VER} &&
 cp -f mk/LICENSE.txt LICENSE)

# TAR: Compress archive
tar -f ${DISTNAME}.tar -c ${DISTNAME}
gzip -f ${DISTNAME}.tar

#
# Prepare Source ZIP.
#
echo "Building zip"
rm -fr ${DISTNAME}
cp -fRp ${PROJ} ${DISTNAME}
rm -fR `find ${DISTNAME} \( -name .svn -or -name \*~ -or -name .\*.swp \)`

# ZIP: Prepare text files.
(cd ${DISTNAME} &&
 cat INSTALL			   |sed "s/$/`echo -e \\\r`/" > INSTALL.txt;
 cat README			   |sed "s/$/`echo -e \\\r`/" > README.txt;
 cat ChangeLogs/Release-${VER}.txt |sed "s/$/`echo -e \\\r`/" > RELEASE-${VER}.txt;
 cat mk/LICENSE.txt		   |sed "s/$/`echo -e \\\r`/" > LICENSE.txt;
 rm -f INSTALL README)

# ZIP: Compress archive
zip -8 -q -r ${DISTNAME}.zip ${DISTNAME}

echo "Updating checksums"
openssl md5 ${DISTNAME}.tar.gz > ${DISTNAME}.tar.gz.md5
openssl sha256 ${DISTNAME}.tar.gz >> ${DISTNAME}.tar.gz.md5
openssl md5 ${DISTNAME}.zip > ${DISTNAME}.zip.md5
openssl sha256 ${DISTNAME}.zip >> ${DISTNAME}.zip.md5

echo "Enter passphrase:"
gpg -ab ${DISTNAME}.tar.gz
echo "Enter passphrase again:"
gpg -ab ${DISTNAME}.zip

if [ "$NOUPLOAD" != "Yes" ]; then
	echo "Upload to ${RHOST}?"
	scp -C ${DISTNAME}.* ${RHOST}:${REMOTEDIR}
	scp -C ${PROJ}/ChangeLogs/Release-${VER}.txt ${RHOST}:${CHANGELOGDIR}
fi

if [ "$PHASE" = "stable" ]; then
	echo "*********************************************************"
	echo "TODO:"
	echo "- Update http://sourceforge.net/projects/bsdbuild/"
	echo "- Notify <bsdbuild@hypertriton.com>"
	echo "*********************************************************"
fi
