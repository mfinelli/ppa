# ppa

Packages for my
[PPA](https://launchpad.net/~mfinelli/+archive/ubuntu/supermario).

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
