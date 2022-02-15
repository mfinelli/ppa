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
