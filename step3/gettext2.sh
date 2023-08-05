tar -xaf gettext-0.21.1.tar.xz
cd gettext-0.21.1 
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-0.21.1
make -j`nproc`
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf gettext-0.21.1
