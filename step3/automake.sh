tar -xaf automake-1.16.5.tar.xz
cd automake-1.16.5
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
make -j`nproc`
make install
cd ..
rm -rf automake-1.16.5
