#!/bin/sh -l
sudo mkdir -p /lfs
sudo pacman -S wget
wget --input-file=wget-list-sysv --continue --directory-prefix=sources
LFS=/lfs LFS_SOURCES=sources ./main.sh
