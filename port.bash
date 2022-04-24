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
  surl="https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/fonts-ubuntu-mono-nerd-font/2.1.0-1~focal1~ppa1/fonts-ubuntu-mono-nerd-font_2.1.0.orig.tar.gz"
fi

# we don't have any special zip handling here because we will always need to
# download the "offical" archive from the PPA before porting to new
# distributions
curl -fsSL -o "$fname.orig.tar.gz" "$surl"

# do the build
cd "$1"
debuild -S
cd ../

ls *_source.changes
[[ $SKIP_UPLOAD == true ]] && exit 0
dput ppa:mfinelli/supermario *_source.changes

exit 0
