tar -xaf sysvinit-3.06.tar.xz
cd sysvinit-3.06
patch -Np1 -i ../sysvinit-3.06-consolidated-1.patch
make -j`nproc`
make install
cd ..
rm -rf sysvinit-3.06
