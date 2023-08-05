tar -xaf attr-2.5.1.tar.gz
cd attr-2.5.1
./configure --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/attr-2.5.1
make -j`nproc`
# make check
make install
cd ..
rm -rf attr-2.5.1
