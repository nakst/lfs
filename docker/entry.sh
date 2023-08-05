#!/bin/sh -l

pacman -Syu --noconfirm --needed wget base-devel python
wget --input-file=wget-list-sysv --continue --directory-prefix=sources

git clone https://github.com/nakst/teak.git
cd teak
gcc -o teak teak.c -pthread -ldl
./teak build.teak
cd ..

teak/teak main.teak lfs=lfs lfsSources=sources
