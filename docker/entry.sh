#!/bin/sh -l
pacman -Syu --noconfirm --needed wget base-devel python
wget --input-file=wget-list-sysv --continue --directory-prefix=sources
teak/teak main.teak lfs=lfs lfsSources=sources
