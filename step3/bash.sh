tar -xaf bash-5.2.15.tar.gz
cd bash-5.2.15
./configure --prefix=/usr --without-bash-malloc --with-installed-readline --docdir=/usr/share/doc/bash-5.2.15
make -j`nproc`
make install
cd ..
rm -rf bash-5.2.15
