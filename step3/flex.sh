tar -xaf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4 --disable-static
make -j`nproc`
make check
make install
ln -sv flex /usr/bin/lex
cd ..
rm -rf flex-2.6.4
