tar -xaf tar-1.34.tar.xz
cd tar-1.34
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf tar-1.34
