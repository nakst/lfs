tar -xaf binutils-2.40.tar.xz
cd binutils-2.40
expect -c "spawn ls" | grep "spawn ls"
mkdir -v build
cd       build
../configure --prefix=/usr --sysconfdir=/etc --enable-gold --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64-bit-bfd --with-system-zlib
make tooldir=/usr -j`nproc`
make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,sframe,opcodes}.a
rm -fv /usr/share/man/man1/{gprofng,gp-*}.1
cd ../..
rm -rf binutils-2.40
