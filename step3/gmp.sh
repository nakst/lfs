tar -xaf gmp-6.2.1.tar.xz
cd gmp-6.2.1
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub
./configure --prefix=/usr   --enable-cxx    --disable-static --docdir=/usr/share/doc/gmp-6.2.1
make -j`nproc`
make html
make check 2>&1 | tee gmp-check-log
make install
make install-html
cd ..
rm -rf gmp-6.2.1
