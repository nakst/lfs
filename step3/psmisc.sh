tar -xaf psmisc-23.6.tar.xz
cd psmisc-23.6
./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf psmisc-23.6
