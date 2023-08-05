set +h
set -eux
test $LFS
umask 022

LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=$LFS/tools/bin:/usr/bin
CONFIG_SITE=$LFS/usr/share/config.site

export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

cd $LFS/sources
mv */* .

tar -xaf binutils-2.40.tar.xz
cd binutils-2.40
mkdir build
cd build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT --disable-nls --enable-gprofng=no --disable-werror
make -j`nproc`
make install
cd ../..
rm -rf binutils-2.40

tar -xaf gcc-12.2.0.tar.xz
cd gcc-12.2.0
tar -xf ../mpfr-4.2.0.tar.xz
mv -v mpfr-4.2.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir build
cd build
../configure --target=$LFS_TGT --prefix=$LFS/tools --with-glibc-version=2.37 --with-sysroot=$LFS --with-newlib --without-headers --enable-default-pie --enable-default-ssp --disable-nls --disable-shared --disable-multilib --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
make -j`nproc`
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
cd ..
rm -rf gcc-12.2.0

tar -xaf linux-6.1.11.tar.xz
cd linux-6.1.11
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
cd ..
rm -rf linux-6.1.11

tar -xaf glibc-2.37.tar.xz
cd glibc-2.37
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
patch -Np1 -i ../glibc-2.37-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=3.2 --with-headers=$LFS/usr/include libc_cv_slibdir=/usr/lib
make -j1
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
cd ../..
rm -rf glibc-2.37
$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders

tar -xaf gcc-12.2.0.tar.xz
cd gcc-12.2.0
mkdir build
cd build
../libstdc++-v3/configure --host=$LFS_TGT --build=$(../config.guess) --prefix=/usr --disable-multilib --disable-nls --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0
make -j`nproc`
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
cd ../..
rm -rf gcc-12.2.0

tar -xaf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf m4-1.4.19

tar -xaf ncurses-6.4.tar.gz
cd ncurses-6.4
sed -i s/mawk// configure
mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-normal --with-cxx-shared  --without-debug --without-ada --disable-stripping --enable-widec
make -j`nproc`
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
cd ..
rm -rf ncurses-6.4

tar -xaf bash-5.2.15.tar.gz
cd bash-5.2.15
./configure --prefix=/usr --build=$(sh support/config.guess) --host=$LFS_TGT --without-bash-malloc
make -j`nproc`
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
cd ..
rm -rf bash-5.2.15

tar -xaf coreutils-9.1.tar.xz
cd coreutils-9.1
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
make -j`nproc`
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
cd ..
rm -rf coreutils-9.1

tar -xaf diffutils-3.9.tar.xz
cd diffutils-3.9
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf diffutils-3.9

tar -xaf file-5.44.tar.gz
cd file-5.44
mkdir build
pushd build
../configure --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la
cd ..
rm -rf file-5.44

tar -xaf findutils-4.9.0.tar.xz
cd findutils-4.9.0
./configure --prefix=/usr --localstatedir=/var/lib/locate --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf findutils-4.9.0

tar -xaf gawk-5.2.1.tar.xz
cd gawk-5.2.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf gawk-5.2.1

tar -xaf grep-3.8.tar.xz
cd grep-3.8
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf grep-3.8

tar -xaf gzip-1.12.tar.xz
cd gzip-1.12
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf gzip-1.12

tar -xaf make-4.4.tar.gz
cd make-4.4
sed -e '/ifdef SIGPIPE/,+2 d' -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' -i src/main.c
./configure --prefix=/usr   --without-guile --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf make-4.4

tar -xaf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr   --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf patch-2.7.6

tar -xaf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr --host=$LFS_TGT
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf sed-4.9

tar -xaf tar-1.34.tar.xz
cd tar-1.34
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make -j`nproc`
make DESTDIR=$LFS install
cd ..
rm -rf tar-1.34

tar -xaf xz-5.4.1.tar.xz
cd xz-5.4.1
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.4.1
make -j`nproc`
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la
cd ..
rm -rf xz-5.4.1

tar -xaf binutils-2.40.tar.xz
cd binutils-2.40
sed '6009s/$add_dir//' -i ltmain.sh
mkdir -v build
cd       build
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd
make -j`nproc`
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
cd ../..
rm -rf binutils-2.40

tar -xaf gcc-12.2.0.tar.xz
cd gcc-12.2.0
tar -xf ../mpfr-4.2.0.tar.xz
mv -v mpfr-4.2.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
mkdir -v build
cd       build
../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++
make -j`nproc`
make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc
cd ../..
rm -rf gcc-12.2.0

chown -R root:root $LFS/etc
chown -R root:root $LFS/var
chown -R root:root $LFS/lib64
chown -R root:root $LFS/tools
chown -R root:root $LFS/bin
chown -R root:root $LFS/lib
chown -R root:root $LFS/sbin
chown -R root:root $LFS/usr
chown root:root $LFS/dev
chown root:root $LFS/proc
chown root:root $LFS/sys
chown root:root $LFS/run

chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash --login /step3.sh
