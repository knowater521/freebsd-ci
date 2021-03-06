#!/bin/sh

METADIR=/meta

# config network
cp ${METADIR}/resolv.conf /etc/
ifconfig vtnet0 inet6 `cat ${METADIR}/ip`
route -6 add default fe80::1%vtnet0

SVN_REVISION=`cat /.svn_revision.txt`

newfs /dev/ada2
mkdir /tank
mount -o noatime /dev/ada2 /tank

svnlite co -q svn://svn.freebsd.org/base/head@${SVN_REVISION} /tank/src
#svnlite co -q svn://svn.freebsd.org/ports/head /tank/ports
PORTS_REVISION=`svnlite info --show-item revision svn://svn.freebsd.org/ports/head`
mkdir /tank/ports
cd /tank/ports
svnlite co -q svn://svn.freebsd.org/ports/head/Keywords@${PORTS_REVISION}
svnlite co -q svn://svn.freebsd.org/ports/head/Mk@${PORTS_REVISION}
svnlite co -q svn://svn.freebsd.org/ports/head/Templates@${PORTS_REVISION}
mkdir graphics
cd graphics
svnlite co -q svn://svn.freebsd.org/ports/head/graphics/gpu-firmware-kmod@${PORTS_REVISION}
svnlite co -q svn://svn.freebsd.org/ports/head/graphics/drm-current-kmod@${PORTS_REVISION}
svnlite co -q svn://svn.freebsd.org/ports/head/graphics/drm-legacy-kmod@${PORTS_REVISION}

mkdir -p /usr/src
mkdir -p /usr/ports
mount_nullfs /tank/src /usr/src
mount_nullfs /tank/ports /usr/ports

cd /usr/ports

export HTTP_PROXY=`cat ${METADIR}/http_proxy`

env ASSUME_ALWAYS_YES=yes pkg update

cd /usr/ports/graphics/drm-current-kmod
make -DBATCH package

cd /usr/ports/graphics/drm-legacy-kmod
make -DBATCH package

RESULT=$?
echo ${RESULT} > ${METADIR}/result
