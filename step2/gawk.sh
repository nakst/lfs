tar -xaf gawk-5.2.1.tar.xz
cd gawk-5.2.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf gawk-5.2.1
