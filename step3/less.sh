tar -xaf less-608.tar.gz
cd less-608
./configure --prefix=/usr --sysconfdir=/etc
make -j`nproc`
make install
cd ..
rm -rf less-608
