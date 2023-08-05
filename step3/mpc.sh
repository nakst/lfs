tar -xaf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.3.1
make -j`nproc`
make html
make check
make install
make install-html
cd ..
rm -rf mpc-1.3.1
