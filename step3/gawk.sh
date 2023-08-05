tar -xaf gawk-5.2.1.tar.xz
cd gawk-5.2.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make -j`nproc`
make check
make LN='ln -f' install
mkdir -pv                                   /usr/share/doc/gawk-5.2.1
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.2.1
cd ..
rm -rf gawk-5.2.1
