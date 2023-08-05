tar -xaf diffutils-3.9.tar.xz
cd diffutils-3.9
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf diffutils-3.9
