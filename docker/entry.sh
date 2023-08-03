#!/bin/sh -l
pacman -Sy --noconfirm --needed wget base-devel python
# wget --input-file=wget-list-sysv --continue --directory-prefix=sources
# LFS=lfs LFS_SOURCES=sources LFS_SUDO= ./main.sh
printf '#include <stdio.h>\nint main(){printf("hello world\\\n");return 0;\n}'
gcc -o hello hello.c
./hello
