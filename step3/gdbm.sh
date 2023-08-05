tar -xaf gdbm-1.23.tar.gz
cd gdbm-1.23
./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make -j`nproc`
make check
make install
cd ..
rm -rf gdbm-1.23
