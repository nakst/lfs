tar -xaf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf sed-4.9
