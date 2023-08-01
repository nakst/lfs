#!/bin/bash

set -eux

test $LFS
test $LFS_SOURCES

export LFS=`realpath $LFS`
export LFS_SOURCES=`realpath $LFS_SOURCES`
export LFS_USER=`whoami`

sudo pacman -S --needed base-devel python

sudo mkdir -pv $LFS/etc
sudo mkdir -pv $LFS/var
sudo mkdir -pv $LFS/lib64
sudo mkdir -pv $LFS/tools
sudo mkdir -pv $LFS/usr/bin
sudo mkdir -pv $LFS/usr/lib
sudo mkdir -pv $LFS/usr/sbin
sudo ln -sv usr/bin $LFS/bin
sudo ln -sv usr/lib $LFS/lib
sudo ln -sv usr/sbin $LFS/sbin
sudo chown -v $LFS_USER $LFS/etc
sudo chown -v $LFS_USER $LFS/var
sudo chown -v $LFS_USER $LFS/lib64
sudo chown -v $LFS_USER $LFS/tools
sudo chown -v $LFS_USER $LFS/bin
sudo chown -v $LFS_USER $LFS/lib
sudo chown -v $LFS_USER $LFS/sbin
sudo chown -v $LFS_USER $LFS/usr
sudo chown -v $LFS_USER $LFS/usr/bin
sudo chown -v $LFS_USER $LFS/usr/lib
sudo chown -v $LFS_USER $LFS/usr/sbin

cd "$(dirname "$0")"
sudo cp -v step2.sh $LFS/step2.sh
sudo cp -v step3.sh $LFS/step3.sh
sudo cp -v linux_config $LFS/linux_config
sudo chown -v $LFS_USER $LFS/step2.sh
sudo mkdir $LFS/sources
sudo cp -vr $LFS_SOURCES $LFS/sources
sudo chown -vR $LFS_USER $LFS/sources
# su $LFS_USER - $LFS/step2.sh 
$LFS/step2.sh 

echo -------------------------------------------------
echo You are now ready to install GRUB.
echo You will need to update the fstab file with the partition used.
echo You may need to update the eudev database..?
