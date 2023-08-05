tar -xaf gzip-1.12.tar.xz
cd gzip-1.12
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf gzip-1.12
