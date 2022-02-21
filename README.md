# ppa

Packages for my
[PPA](https://launchpad.net/~mfinelli/+archive/ubuntu/supermario).

TODO: add note about editing the PPA settings to enable other architectures

## gpg

We use a dedicated GPG key for signing since we need to store the private key
as a GitHub secret in order to enable the desired automation.

Use `gpg --full-gen-key` to generate a 4096 bit RSA key that doesn't expire and
which doesn't have a password. Then export it and encrypt it in this repository
for safe keeping in the event that we need it again after exporting it to
GitHub (from where it cannot be retrieved again).

```shell
gpg --export-secret-keys 01EF7C8B | gpg -ear 36FDA306 > admin/01EF7C8B.asc
```

The key must also be exported to the _Ubuntu_ keyserver:

```shell
gpg --send-keys --keyserver keyserver.ubuntu.com 01EF7C8B
```

## backports

To "backport" a package from a newer version of Ubuntu into the current LTS
you need to first find the `orig.tar.xz` of the package and add it into the
`build.bash` script where the backports are currently hardcoded. Then you
need to grab the debian archive and extract its contents into the package
directory.

Commit, and then add a new changelog entry in a new commit to have it build
the newer package for the older release.

For example, `ansible`:

```shell
wget https://mirror.umd.edu/ubuntu/ubuntu/pool/universe/a/ansible/ansible_2.10.7+merged+base+2.10.8+dfsg-1.debian.tar.xz
cd ansible
tar xf ../ansible*.tar.xz
```

## new packages

To create a new package, download the source tarball and then run:

```shell
mkdir -p packagename
cd packagename
dh_make -f ./path/to/source.tar.gz -p pkgname_pkgver -s -y
git commit -m "Add new package pkgname"
```

To enable the automated builder to download the original source, you will need
to add a special comment to the `debian/control` file with the URL to the
source: `# Source-Archive: https://example.com/package.tar.gz`.

Then proceed to modify as necessary and create the test/publish workflow.

## resources

- Get valid section names: https://packages.debian.org/bullseye/
- Upload steps: https://help.launchpad.net/Packaging/PPA/Uploading
- Package naming conventions: https://askubuntu.com/a/4951
- Package naming conventions: https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage#Versioning
- Building for multiple architectures: https://askubuntu.com/a/765149
