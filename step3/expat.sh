tar -xaf expat-2.5.0.tar.xz
cd expat-2.5.0
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-2.5.0
make -j`nproc`
make check
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.5.0
cd ..
rm -rf expat-2.5.0
