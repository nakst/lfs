tar -xaf libffi-3.4.4.tar.gz
cd libffi-3.4.4
./configure --prefix=/usr --disable-static --with-gcc-arch=x86-64
make -j`nproc`
make check
make install
cd ..
rm -rf libffi-3.4.4
