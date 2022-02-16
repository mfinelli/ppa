#!/bin/sh
grep UBUNTU_CODENAME /etc/os-release | awk -F= '{print $2}'
