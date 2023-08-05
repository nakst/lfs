tar -xaf xz-5.4.1.tar.xz
cd xz-5.4.1
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.4.1
make -j`nproc`
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la
cd ..
rm -rf xz-5.4.1
