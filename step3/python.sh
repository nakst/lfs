tar -xaf Python-3.11.2.tar.xz
cd Python-3.11.2
./configure --prefix=/usr   --enable-shared --without-ensurepip
make -j`nproc`
make install
cd ..
rm -rf Python-3.11.2
