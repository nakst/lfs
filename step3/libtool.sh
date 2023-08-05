tar -xaf libtool-2.4.7.tar.xz
cd libtool-2.4.7
./configure --prefix=/usr
make -j`nproc`
make install
rm -fv /usr/lib/libltdl.a
cd ..
rm -rf libtool-2.4.7
