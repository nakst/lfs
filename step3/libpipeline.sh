tar -xaf libpipeline-1.5.7.tar.gz
cd libpipeline-1.5.7
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf libpipeline-1.5.7
