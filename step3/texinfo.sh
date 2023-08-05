tar -xaf texinfo-7.0.2.tar.xz
cd texinfo-7.0.2
./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf texinfo-7.0.2
