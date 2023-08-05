tar -xaf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr --disable-static
make -j`nproc`
make check
make docdir=/usr/share/doc/check-0.15.2 install
cd ..
rm -rf check-0.15.2
