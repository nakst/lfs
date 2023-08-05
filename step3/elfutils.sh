tar -xaf elfutils-0.188.tar.bz2
cd elfutils-0.188
./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make -j`nproc`
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
cd ..
rm -rf elfutils-0.188
