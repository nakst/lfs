tar -xaf file-5.44.tar.gz
cd file-5.44
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf file-5.44
