#!/usr/bin/env bash

set -ex

# applies a patch to convert the package into a release that we're _not_
# running on and then publishes it to the PPA
# usage: ./port.bash package release
#
# example: ./port.bash fonts-ubuntu-mono-nerd-font jammy
# assuming you're running on a host that isn't jammy (e.g., focal) it will
# apply the jammy patch and then publish

if [[ $# -ne 2 ]]; then
  echo >&2 "usage: $(basename "$0") package release"
  exit 1
fi

if [[ ! -f $1/$2.patch ]]; then
  echo >&2 "error: unable to find $2 patch for $1"
  exit 1
fi

# first apply the patch for the distribution relase
patch -p1 -N -i "$1/$2.patch"
# then remove all patch files as they interfere with the build process
find "$1" -name '*.patch' -maxdepth 1 -exec rm -v {} \;

# download the sources like we do normally
surl="$(grep -m1 '^# Source-Archive: ' "$1/debian/control" |
  sed 's/^# Source-Archive: //')"
fname="$(head -n1 "$1/debian/changelog" | sed 's/^\(.*\) (\(.*\)) .*$/\1_\2/' |
  sed 's/^\(.*\)-.*/\1/')"

if [[ $1 == fonts-ubuntu-mono-nerd-font ]]; then
  # because we repack the original zip file into a tar gz, the timestamp
  # header changes and launchpad rejects the upload as using a different
  # source. resolve by downloading directly the original source from the PPA
  # https://help.launchpad.net/Packaging/UploadErrors#Apparently_successful_upload_followed_by_a_rejection_email
  surl="https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/fonts-ubuntu-mono-nerd-font/3.3.0-1~jammy1~ppa1/fonts-ubuntu-mono-nerd-font_3.3.0.orig.tar.gz"
elif [[ $1 == fonts-iosevka ]]; then
  surl="https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/fonts-iosevka/33.2.7-1~jammy1~ppa1/fonts-iosevka_33.2.7.orig.tar.gz"
fi

if [[ $1 == gnome-shell-extension-espresso ]]; then
  if [[ $2 == jammy ]]; then
    surl="https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/gnome-shell-extension-espresso/8-1~jammy1~ppa1/gnome-shell-extension-espresso_8.orig.tar.gz"
  elif [[ $2 == noble ]]; then
    surl="https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/gnome-shell-extension-espresso/10-1~noble1~ppa1/gnome-shell-extension-espresso_10.orig.tar.gz"
  fi

  curl -fsSL -o "$fname.orig.tar.gz" "$surl"

  # NB: when we have a new version do this:
  # we do the zip handling here because we have different versions between
  # jammy and noble
  # curl -fsSL -o tmp.zip "$surl"
  # ./zip2tar.bash tmp.zip "$fname.orig.tar.gz"
  # rm tmp.zip
else
  # we don't have any special zip handling here because we will always need to
  # download the "offical" archive from the PPA before porting to new
  # distributions
  curl -fsSL -o "$fname.orig.tar.gz" "$surl"
fi

# do the build
cd "$1"
debuild -S
cd ../

ls ./*_source.changes
[[ $SKIP_UPLOAD == true ]] && exit 0
dput ppa:mfinelli/supermario ./*_source.changes

exit 0
