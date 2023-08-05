tar -xaf gzip-1.12.tar.xz
cd gzip-1.12
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf gzip-1.12
