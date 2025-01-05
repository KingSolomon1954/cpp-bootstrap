#!/usr/bin/env bash
#
# -----------------------------------------------------------
#
# Performs a minimal checkout of the tar ball.
#
# -----------------------------------------------------------

# $1 = build directory   _build
# $2 = tar-file          _build/release/RedFlame-0.0.3.tgz

b=$(basename $2)         # RedFlame-0.0.3.tgz
release="${b%%".tgz"}"   # strip .tgz

testdir=$1/test-tarball
rm -rf   $testdir
mkdir -p $testdir
tar -xzf $2 --directory=$testdir

releaseDir=$testdir/$release

[ ! -d $releaseDir ]              && exit 1
[ ! -x $releaseDir/RedFlame ]     && exit 1
[ ! -x $releaseDir/RedFlame-db ]  && exit 1
[ ! -f $releaseDir/version ]      && exit 1
[ ! -f $releaseDir/changelog.md ] && exit 1

exit 0
