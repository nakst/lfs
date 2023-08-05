tar -xaf zlib-1.2.13.tar.xz
cd zlib-1.2.13
./configure --prefix=/usr
make -j`nproc` 
make check
make install
rm -fv /usr/lib/libz.a
cd ..
rm -rf zlib-1.2.13
