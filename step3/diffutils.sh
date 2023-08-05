tar -xaf diffutils-3.9.tar.xz
cd diffutils-3.9
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf diffutils-3.9
