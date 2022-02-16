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
if [[ $1 == ansible ]]; then
  cd ../build-area
  # use the UMD mirror -- archive.ubuntu.com is not available over https
  wget https://mirror.umd.edu/ubuntu/ubuntu/pool/universe/a/ansible/ansible_2.10.7+merged+base+2.10.8+dfsg.orig.tar.xz
  cd ../ppa
else
  cd "$1"

  # download the source into the correct location
  surl="$(grep -m1 '^# Source-Archive: ' debian/control |
    sed 's/^# Source-Archive: //')"
  fname="$(head -n1 debian/changelog | sed 's/^\(.*\) (\(.*\)) .*$/\1_\2/')"
  curl -fsSL -o "../$fname.orig.tar.gz" "$surl"

  cd ../
fi

ls
cd "$1"
ls

brz builddeb -S
cd ../../build-area
pbuilder-dist "$codename" build *.dsc

[[ $SKIP_UPLOAD == true ]] && exit 0
dput ppa:mfinelli/supermario *_source.changes

exit 0
