tar -xaf findutils-4.9.0.tar.xz
cd findutils-4.9.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make -j`nproc`
chown -Rv tester .
su tester -c "PATH=$PATH make check"
make install
cd ..
rm -rf findutils-4.9.0
