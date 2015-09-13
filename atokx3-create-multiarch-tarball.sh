#!/bin/sh

while [ $# -gt 0 ]; do
  case $1 in
    -d)
      debug=$1
      shift 1
      ;;
    *)
      break
  esac
done

tarball=$1
basename=`basename $tarball .tar.gz`

if [ ! -f "$tarball" ]; then
  echo 'no such file: $tarball' >&2
  exit 1
fi

# create a temporary directory
workdir=`mktemp -d --suffix=.$basename` || exit $?
chmod 755 $workdir
if [ -n "$debug" ]; then
  echo "# $tarball working directory: $workdir"
fi

# extract tarball contents to the temporary directory
tar xzf $tarball -C $workdir
if [ -n "$debug" ]; then
  echo "# $tarball before:"
  tar tzf $tarball
fi

# move /usr/lib/* to /usr/lib/i386-linux-gnu/
if [ -d $workdir/usr/lib ]; then
  mkdir $workdir/usr/lib/.i386-linux-gnu || exit $?
  mv $workdir/usr/lib/* $workdir/usr/lib/.i386-linux-gnu/ || exit $?
  mv $workdir/usr/lib/.i386-linux-gnu $workdir/usr/lib/i386-linux-gnu || exit $?
fi

# but don't move /usr/lib/iiim; restore it
## /usr/lib/iiim/iiim-xbe has hardcorded /usr/lib/iiim/xiiimp.so.2
## /usr/lib/iiim/xiiimp.so.2 has hardcorded /usr/lib/iiim/le
if [ -d $workdir/usr/lib/i386-linux-gnu/iiim ]; then
  mv $workdir/usr/lib/i386-linux-gnu/iiim $workdir/usr/lib/ || exit $?
  if [ -z "`ls $workdir/usr/lib/i386-linux-gnu`" ]; then
    rmdir $workdir/usr/lib/i386-linux-gnu
  fi
fi

# move /usr/lib64/* to /usr/lib/x86_64-linux-gnu/
if [ -d $workdir/usr/lib64 ]; then
  if [ ! -d $workdir/usr/lib/x86_64-linux-gnu ]; then
    mkdir -p $workdir/usr/lib/x86_64-linux-gnu || exit $?
  fi
  mv $workdir/usr/lib64/* $workdir/usr/lib/x86_64-linux-gnu/ || exit $?
  rmdir $workdir/usr/lib64 || exit $?
fi

# create a tarball of new contents
newtarball=`mktemp --suffix=.$basename.tar.gz` || exit $?
tar czf $newtarball -C $workdir . || exit $?
if [ -n "$debug" ]; then
  echo "# $tarball after:"
  tar tzf $newtarball
fi

# replace the tarball
mv $newtarball $tarball || exit $?

# clean up
if [ -z "$debug" ]; then
  rm -rf $workdir || exit $?
fi
