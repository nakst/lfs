#!/bin/sh -l
mkdir -p /lfs
pacman -Sy wget
wget --input-file=wget-list-sysv --continue --directory-prefix=sources
LFS=/lfs LFS_SOURCES=sources LFS_SUDO= ./main.sh
