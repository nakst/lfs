tar -xaf xz-5.4.1.tar.xz
cd xz-5.4.1
./configure --prefix=/usr    --disable-static --docdir=/usr/share/doc/xz-5.4.1
make -j`nproc`
make check
make install
cd ..
rm -rf xz-5.4.1
