tar -xaf grep-3.8.tar.xz
cd grep-3.8
sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf grep-3.8
