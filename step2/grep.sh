tar -xaf grep-3.8.tar.xz
cd grep-3.8
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf grep-3.8
