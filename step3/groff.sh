tar -xaf groff-1.22.4.tar.gz
cd groff-1.22.4
PAGE=A4 ./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf groff-1.22.4
