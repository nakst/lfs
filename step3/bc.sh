tar -xaf bc-6.2.4.tar.xz
cd bc-6.2.4
CC=gcc ./configure --prefix=/usr -G -O3 -r
make -j`nproc`
make test
make install
cd ..
rm -rf bc-6.2.4
