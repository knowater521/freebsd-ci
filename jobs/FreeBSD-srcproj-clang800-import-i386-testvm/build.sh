#!/bin/sh

export JFLAG=${BUILDER_JFLAG}

export TARGET=i386
export TARGET_ARCH=i386

export WITH_LIB32=1
export WITH_DEBUG=1
export WITH_DOC=1
export WITH_TESTS=1

sh -x freebsd-ci/scripts/build/build-test_image.sh
