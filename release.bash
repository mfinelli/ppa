#!/bin/bash -ex

if [[ $# -ne 1 ]]; then
  echo >&2 "usage: $(basename "$0") package"
  exit 1
fi

codename="$(./codename.sh)"

mkdir -p ../build-area

# for "backport" sources we have special handling, we need to download the
# original sources from ubuntu and place them in the correct place.
# we have very few backport sources, so we just hardcode them here
if [[ $1 == gnome-shell-extension-espresso ]]; then
  cd ../build-area

  if [[ $codename == jammy ]]; then
    wget https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/gnome-shell-extension-espresso/8-1~jammy1~ppa1/gnome-shell-extension-espresso_8.orig.tar.gz
  elif [[ $codename == noble ]]; then
    wget https://launchpad.net/~mfinelli/+archive/ubuntu/supermario/+sourcefiles/gnome-shell-extension-espresso/10-1~noble1~ppa1/gnome-shell-extension-espresso_10.orig.tar.gz
  fi

  cd ../ppa
else
  cd "$1"

  # download the source into the correct location
  surl="$(grep -m1 '^# Source-Archive: ' debian/control |
    sed 's/^# Source-Archive: //')"
  fname="$(head -n1 debian/changelog | sed 's/^\(.*\) (\(.*\)) .*$/\1_\2/' |
    sed 's/^\(.*\)-.*/\1/')"

  if [[ $(basename "$surl") =~ \.zip$ ]]; then
    # if we have a zip then unzip it and repack it into a tarball
    # the debian build system can't handle zips
    curl -fsSL -o tmp.zip "$surl"
    ../zip2tar.bash tmp.zip "../../$fname.orig.tar.gz"
    rm tmp.zip
  else
    # otherwise just download it like normal
    curl -fsSL -o "../../$fname.orig.tar.gz" "$surl"
  fi

  cd ../
fi

# remove any patches we have for other relase distributions because
# they interfere with the build process
find "$1" -name '*.patch' -maxdepth 1 -exec rm -v {} \;

cd "$1"

brz builddeb -S
cd ../../build-area
pbuilder-dist "$codename" build ./*.dsc

[[ $SKIP_UPLOAD == true ]] && exit 0
dput ppa:mfinelli/supermario ./*_source.changes

exit 0
