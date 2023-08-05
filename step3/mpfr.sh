tar -xaf mpfr-4.2.0.tar.xz
cd mpfr-4.2.0
sed -e 's/+01,234,567/+1,234,567 /' -e 's/13.10Pd/13Pd/' -i tests/tsprintf.c
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.2.0
make -j`nproc`
make html
make check
make install
make install-html
cd ..
rm -rf mpfr-4.2.0
