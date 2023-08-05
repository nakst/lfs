tar -xaf inetutils-2.4.tar.xz
cd inetutils-2.4
./configure --prefix=/usr --bindir=/usr/bin --localstatedir=/var --disable-logger --disable-whois --disable-rcp --disable-rexec --disable-rlogin --disable-rsh --disable-servers
make -j`nproc`
# make check
make install
mv -v /usr/{,s}bin/ifconfig
cd ..
rm -rf inetutils-2.4
