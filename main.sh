#!/bin/bash

set -eux

test $LFS
test $LFS_SOURCES

export LFS=`realpath $LFS`
export LFS_SOURCES=`realpath $LFS_SOURCES`
export LFS_USER=`whoami`

$LFS_SUDO mkdir -pv $LFS/etc
$LFS_SUDO mkdir -pv $LFS/var
$LFS_SUDO mkdir -pv $LFS/lib64
$LFS_SUDO mkdir -pv $LFS/tools
$LFS_SUDO mkdir -pv $LFS/usr/bin
$LFS_SUDO mkdir -pv $LFS/usr/lib
$LFS_SUDO mkdir -pv $LFS/usr/sbin
$LFS_SUDO ln -sv usr/bin $LFS/bin
$LFS_SUDO ln -sv usr/lib $LFS/lib
$LFS_SUDO ln -sv usr/sbin $LFS/sbin
$LFS_SUDO chown -v $LFS_USER $LFS/etc
$LFS_SUDO chown -v $LFS_USER $LFS/var
$LFS_SUDO chown -v $LFS_USER $LFS/lib64
$LFS_SUDO chown -v $LFS_USER $LFS/tools
$LFS_SUDO chown -v $LFS_USER $LFS/bin
$LFS_SUDO chown -v $LFS_USER $LFS/lib
$LFS_SUDO chown -v $LFS_USER $LFS/sbin
$LFS_SUDO chown -v $LFS_USER $LFS/usr
$LFS_SUDO chown -v $LFS_USER $LFS/usr/bin
$LFS_SUDO chown -v $LFS_USER $LFS/usr/lib
$LFS_SUDO chown -v $LFS_USER $LFS/usr/sbin

cd "$(dirname "$0")"
$LFS_SUDO cp -v step2.sh $LFS/step2.sh
$LFS_SUDO cp -v step3.sh $LFS/step3.sh
$LFS_SUDO cp -v linux_config $LFS/linux_config
$LFS_SUDO chown -v $LFS_USER $LFS/step2.sh
$LFS_SUDO mkdir $LFS/sources
$LFS_SUDO cp -vr $LFS_SOURCES $LFS/sources
$LFS_SUDO chown -vR $LFS_USER $LFS/sources
# su $LFS_USER - $LFS/step2.sh 
$LFS/step2.sh 

echo -------------------------------------------------
echo You are now ready to install GRUB.
echo You will need to update the fstab file with the partition used.
echo You may need to update the eudev database..?
