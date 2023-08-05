tar -xaf libcap-2.67.tar.xz
cd libcap-2.67
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
cd ..
rm -rf libcap-2.67
