#!/bin/sh

atokx3_productdir=$1

for tarball in $atokx3_productdir/bin/tarball/*/*.tar.gz; do
  echo ==== $tarball ====
  tar tzf $tarball
done
