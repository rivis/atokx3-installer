#!/bin/sh

if ! type fakeroot > /dev/null 2>&1; then
  echo fakeroot must be installed. >&2
  exit 1
fi

while [ $# -gt 0 ]; do
  case $1 in
    -g)
      gtk3_im_iiim_so=$2
      shift 2
      ;;
    -h)
      hide_status=$1
      shift 1
      ;;
    -s)
      shift_space=$1
      shift 1
      ;;
    -d)
      debug=$1
      shift 1
      ;;
    *)
      break
  esac
done

atokx3_productdir=$1
atokx3up2_tarball=$2
atokx3gtk216_tarball=$3
a20y1311lx_tarball=$4
libpangox32_deb=$5
libpangox64_deb=$6
iiimf_status_hide=$7

gtk2query32=/usr/lib/i386-linux-gnu/libgtk2.0-0/gtk-query-immodules-2.0
gtk2query64=/usr/lib/x86_64-linux-gnu/libgtk2.0-0/gtk-query-immodules-2.0
gtk2immod32=/usr/lib/i386-linux-gnu/gtk-2.0/2.10.0/immodules.cache
gtk2immod64=/usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache

gtk3query64=/usr/lib/x86_64-linux-gnu/libgtk-3-0/gtk-query-immodules-3.0
gtk3immod64=/usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
gtk3immod64_dir=/usr/lib/x86_64-linux-gnu/gtk-3.0/immodules

pkgs_i386="
libcrypt1:i386
libgtk2.0-0:i386
libice6:i386
libpam0g:i386
libpangox-1.0-0:i386
libpangoxft-1.0-0:i386
libsm6:i386
libstdc++6:i386
libwrap0:i386
libxml2:i386
libxt6:i386
gtk2-engines:i386
"

old_conf_files="
/etc/gtk-2.0/gtk.immodules
"

# show usage message
usage() {
  cat <<-EOF
	Usage:
	  $0
	     [-g gtk3_im_iiim_so] [-h] [-s] [-d]
	     atokx3_productdir atokx3up2_tarball
	     atokx3gtk216_tarball a20y1311lx_tarball
             libpangox32_deb libpangox64_deb
             [iiimf_status_hide]
	Options:
	  -g gtk3_im_iiim_so:
	    Install the given im-iiim.so file for GTK+ 3.x (x86_64)
	    Filename:
	      im-iiim.so
	    Downloadable at:
	      http://mikeforce.net/trac/iiimgcf/wiki
	  -h:
	    Install iiimf_status_hide
	  -s:
	    Use shift-space instead of ctrl-space
	  -d:
	    Show debug messages and keep temporary directories
	Arguments:
	  atokx3_productdir:
	    Directory which contains ATOK X3 for Linux product
	  atokx3up2_tarball:
	    Tarball of ATOK X3 for Linux update module
	    Fielname:
	      atokx3up2.tar.gz
	    Downloadable at:
	       http://support.justsystems.com/faq/1032/app/servlet/qadoc?QID=042459
	  atokx3gtk216_tarball:
	    Tarball of ATOK X3 for Linux Ubuntu 9.04 (GTK+ 2.16) module
	    Filename:
	      atokx3gtk216.tar.gz
	    Downloadable at:
	      http://support.justsystems.com/faq/1032/app/servlet/qadoc?QID=044668
	  a20y1311lx_tarball:
	    Tarball of ATOK X3 for Linux prefecture code dictionary
	    Filename:
	      a20y1311lx.tgz
	    Downloadable at:
	      http://support.justsystems.com/faq/1032/app/servlet/qadoc?QID=042740
	  libpangox32_deb
	    Debian package for i386 version of libpangox
	    Filename:
	      libpangox-*_i386.deb
	    Downloadable at:
	      http://ftp.debian.org/debian/pool/main/p/pangox-compat/
	  libpangox64_deb
	    Debian package for amd64 version of libpangox
	    Filename:
	      libpangox-*_amd64.deb
	    Downloadable at:
	      http://ftp.debian.org/debian/pool/main/p/pangox-compat/
	  iiimf_status_hide
	    Executable file of iiimf_status_hide
	    Used only if -h option is specified
	    Filename:
	      iiimf_status_hide or iiimf_status_hide.gz
	    Downloadable at:
	      http://support.justsystems.com/faq/1032/app/servlet/qadoc?QID=037494
EOF
}

# check arguments
if [ ! -d "$atokx3_productdir" ]; then
  echo "invalid atokx3_productdir: $atokx3_productdir" >&2
  usage
  exit 1
fi
if [ ! -f "$atokx3up2_tarball" ]; then
  echo "invalid atokx3up2_tarball: $atokx3up2_tarball" >&2
  usage
  exit 1
fi
if [ ! -f "$atokx3gtk216_tarball" ]; then
  echo "invalid atokx3gtk216_tarball: $atokx3gtk216_tarball" >&2
  usage
  exit 1
fi
if [ ! -f "$a20y1311lx_tarball" ]; then
  echo "invalid a20y1311lx_tarball: $a20y1311lx_tarball" >&2
  usage
  exit 1
fi
if [ ! -f "$libpangox32_deb" ]; then
  echo "invalid libpangox32_deb: $libpangox32_deb" >&2
  usage
  exit 1
fi
if [ ! -f "$libpangox64_deb" ]; then
  echo "invalid libpangox64_deb: $libpangox64_deb" >&2
  usage
  exit 1
fi
if [ -n "$iiimf_status_hide" -a ! -f "$iiimf_status_hide" ]; then
  echo "invalid iiimf_status_hide: $iiimf_status_hide" >&2
  usage
  exit 1
fi
if [ -n "$gtk3_im_iiim_so" -a ! -f "$gtk3_im_iiim_so" ]; then
  echo "invalid gtk3 im-iiim.so: $gtk3_im_iiim_so" >&2
  usage
  exit 1
fi

# prepare for i386 multiarch
sudo dpkg --add-architecture i386 || exit $?
sudo apt-get update               || exit $?
sudo apt-get install $pkgs_i386   || exit $?

# install packages removed from the Debian package repository
sudo dpkg -i $libpangox32_deb || exit $?
sudo dpkg -i $libpangox64_deb || exit $?

# create a temporary directory
workdir=`mktemp -d` || exit $?

# copy the atokx3 directory and extract the atokx3up2 tarball contents
# to the temporary directory
cp -pr  $atokx3_productdir $workdir/atokx3 || exit $?
tar xzf $atokx3up2_tarball -C $workdir     || exit $?

# adapt directory structure in tarballs to Debian multi-arch
for tarball in $workdir/atokx3/bin/tarball/*/*.tar.gz \
               $workdir/atokx3up2/bin/*/*.tar.gz; do
  fakeroot `dirname $0`/atokx3-create-multiarch-tarball.sh $debug $tarball \
    || exit $?
done

# add Debian paths to path lists in the setup script
sed -i $workdir/atokx3/setupatok_tar.sh \
  -e '/^gtkquerylist32="\$list"/ i\list="$list '$gtk2query32'"' \
  -e '/^gtkquerylist64="\$list"/ i\list="$list '$gtk2query64'"' \
  -e '/^gtkimmodlist32="\$list"/ i\list="$list '$gtk2immod32'"' \
  -e '/^gtkimmodlist64="\$list"/ i\list="$list '$gtk2immod64'"' \
  || exit $?

# delete configuration files if ones for older Debian version exists
for file in $old_conf_files; do
  if [ -f "$file" ]; then
    echo -n "File $file exists. Delete this file? (yes/no) "
    read ans
    case "$ans" in
      [Yy]*)
        sudo rm $file
        ;;
    esac
  fi
done

# install ATOK X3 and its update modules
sudo bash $workdir/atokx3/setupatok_tar.sh        $workdir/atokx3 || exit $?
sudo bash $workdir/atokx3up2/setupatok_up2_tar.sh $workdir/atokx3 || exit $?
sudo tar xzf $atokx3gtk216_tarball -C / || exit $?
sudo tar xzf $a20y1311lx_tarball   -C / || exit $?
# don't run setting_debian4.sh because it is required only by im-switch
#sudo /opt/atokx3/sample/setting_debian4.sh || exit $?

# restore the /var/run symbolic link overwritten by
# iiimf-server-trunk_r3104-js1.i386.tar.gz extracted in setupatok_tar.sh
if [ -d /var/run -a -d /run ]; then
  sudo mv /var/run/iiim /run || exit $?
  sudo rmdir /var/run || exit $?
  sudo ln -s /run /var/run || exit $?
fi

# create the start-up script for im-config because setting_debian4.sh creates
# the start-up script only for im-switch but im-config is installed instead
# by Debian Jessie Japanese Task
cat <<-'EOF' | sudo tee /opt/atokx3/sample/xinputrc > /dev/null || exit $?
	if [ "$IM_CONFIG_PHASE" != 2 ]; then
	  XMODIFIERS=@im=iiimx
	  GTK_IM_MODULE=iiim
	  QT_IM_MODULE=xim
	  HTT_DISABLE_STATUS_WINDOW=t
	  HTT_GENERATES_KANAKEY=t
	  HTT_USES_LINUX_XKEYSYM=t
	  HTT_IGNORES_LOCK_MASK=t
	  JS_FEEDBACK_CONVERT=t
	  export HTT_DISABLE_STATUS_WINDOW
	  export HTT_GENERATES_KANAKEY
	  export HTT_IGNORES_LOCK_MASK
	  export HTT_IGNORES_LOCK_MASK
	  export JS_FEEDBACK_CONVERT
	else
	  /usr/bin/iiimx -iiimd
	fi
EOF

# install im-iiim.so for GTK+ 3.x (x86_64) and re-create the cache
if [ -n "$gtk3_im_iiim_so" ]; then
  sudo mkdir -p $gtk3immod64_dir || exit $?
  sudo cp -p $gtk3_im_iiim_so $gtk3immod64_dir/ || exit $?
  sudo chown root:root $gtk3immod64_dir/`basename $gtk3_im_iiim_so` || exit $?
  sudo chmod 644 $gtk3immod64_dir/`basename $gtk3_im_iiim_so` || exit $?
  $gtk3query64 | sudo tee $gtk3immod64 > /dev/null || exit $?
fi

# install iiimf_status_hide
if [ -n "$hide_status" ]; then
  # did user specified iiimf_status_hide as an argument?
  if [ -n "$iiimf_status_hide" ]; then
    # gunzip if the filename ends with .gz
    if echo "$iiimf_status_hide" | grep '\.gz$' > /dev/null; then
      gunzip $iiimf_status_hide || exit $?
      iiimf_status_hide=`echo $iiimf_status_hide | sed -e 's/\.gz$//'`
    fi
  else
    # download iiimf_status_hide from JustSystems site
    wget -P $workdir \
      http://www3.justsystem.co.jp/download/atok/ut/lin/iiimf_status_hide.gz \
      || exit $?
    iiimf_status_hide=$workdir/iiimf_status_hide
    gunzip ${iiimf_status_hide}.gz || exit $?
  fi
  # put it in /opt/atokx3/sample/
  sudo cp -p $iiimf_status_hide /opt/atokx3/sample/ || exit $?
  sudo chown root:root /opt/atokx3/sample/iiimf_status_hide || exit $?
  sudo chmod 755 /opt/atokx3/sample/iiimf_status_hide || exit $?
  # modify the start-up script for im-config
  sudo sed -i /opt/atokx3/sample/xinputrc \
    -e '/^  \/usr\/bin\/iiimx / i\  /opt/atokx3/sample/iiimf_status_hide' \
    || exit $?
fi

# configure to use shift-space instead of ctrl-space
if [ -n "$shift_space" ]; then
  sudo sed -i /etc/iiim/js_triggerkeys.conf \
    -e 's/^Shift+space no$/Shift+space yes/' \
    || exit $1
fi

# clean up
if [ -z "$debug" ]; then
  rm -rf $workdir || exit $?
fi
