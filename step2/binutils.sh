tar -xaf binutils-2.40.tar.xz
cd binutils-2.40
mkdir build
cd build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT --disable-nls --enable-gprofng=no --disable-werror
make -j`nproc`
make install
cd ../..
rm -rf binutils-2.40
