#!/bin/sh -l
pacman -Syu --noconfirm --needed wget base-devel python
wget --input-file=wget-list-sysv --continue --directory-prefix=sources
LFS=lfs LFS_SOURCES=sources LFS_SUDO= ./main.sh
