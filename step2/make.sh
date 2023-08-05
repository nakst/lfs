tar -xaf make-4.4.tar.gz
cd make-4.4
sed -e '/ifdef SIGPIPE/,+2 d' -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' -i src/main.c
./configure --prefix=/usr   --without-guile --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf make-4.4
