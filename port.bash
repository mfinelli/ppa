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

if [[ $(basename "$surl") =~ \.zip$ ]]; then
  # if we have a zip then unzip it and repack it into a tarball
  # the debian build system can't handle zips
  curl -fsSL -o tmp.zip "$surl"
  ./zip2tar.bash tmp.zip "$fname.orig.tar.gz"
  rm tmp.zip
else
  # otherwise just download it like normal
  curl -fsSL -o "$fname.orig.tar.gz" "$surl"
fi

# do the build
cd "$1"
debuild -S
cd ../

ls *_source.changes
[[ $SKIP_UPLOAD == true ]] && exit 0
dput ppa:mfinelli/supermario *_source.changes

exit 0
