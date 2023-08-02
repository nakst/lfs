#!/bin/bash

# The following test suites are not run because they contains failures:
# 	glibc, binutils, gcc, libtool, automake, elfutils, coreutils, 
# 	tar, procps-ng, util-linux, e2fsprogs, eudev, attr (needs extended attribute support)

set -eux

mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

ln -sv /proc/self/mounts /etc/mtab

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

cd /sources

tar -xaf gettext-0.21.1.tar.xz
cd gettext-0.21.1
./configure --disable-shared
make -j`nproc`
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
cd ..
rm -rf gettext-0.21.1

tar -xaf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make -j`nproc`
make install
cd ..
rm -rf bison-3.8.2

tar -xaf perl-5.36.0.tar.xz
cd perl-5.36.0
sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.36/core_perl     \
             -Darchlib=/usr/lib/perl5/5.36/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.36/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.36/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl
make -j`nproc`
make install
cd ..
rm -rf perl-5.36.0

tar -xaf Python-3.11.2.tar.xz
cd Python-3.11.2
./configure --prefix=/usr   --enable-shared --without-ensurepip
make -j`nproc`
make install
cd ..
rm -rf Python-3.11.2

tar -xaf texinfo-7.0.2.tar.xz
cd texinfo-7.0.2
./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf texinfo-7.0.2

tar -xaf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --libdir=/usr/lib    \
            --docdir=/usr/share/doc/util-linux-2.38.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            runstatedir=/run
make -j`nproc`
make install
cd ..
rm -rf util-linux-2.38.1

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools

tar -xaf man-pages-6.03.tar.xz
cd man-pages-6.03
make prefix=/usr install
cd ..
rm -rf man-pages-6.03

tar -xaf iana-etc-20230202.tar.gz
cd iana-etc-20230202
cp services protocols /etc
cd ..
rm -rf iana-etc-20230202

tar -xaf glibc-2.37.tar.xz
cd glibc-2.37
patch -Np1 -i ../glibc-2.37-fhs-1.patch
sed '/width -=/s/workend - string/number_length/' -i stdio-common/vfprintf-process-arg.c
touch /etc/ld.so.conf
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=3.2                      \
             --enable-stack-protector=strong          \
             --with-headers=/usr/include              \
             libc_cv_slibdir=/usr/lib
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
cd ../..
rm -rf glibc-2.37

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

mkdir -p tzdata2022g
cd tzdata2022g
tar -xf ../tzdata2022g.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
cd ..
rm -rf tzdata2022g
ln -sfv /usr/share/zoneinfo/GMT /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

tar -xaf zlib-1.2.13.tar.xz
cd zlib-1.2.13
./configure --prefix=/usr
make -j`nproc` 
make check
make install
rm -fv /usr/lib/libz.a
cd ..
rm -rf zlib-1.2.13

tar -xaf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make -j`nproc`
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2
ln -sfv bzip2 /usr/bin/bzcat
ln -sfv bzip2 /usr/bin/bunzip2
rm -fv /usr/lib/libbz2.a
cd ..
rm -rf bzip2-1.0.8

tar -xaf xz-5.4.1.tar.xz
cd xz-5.4.1
./configure --prefix=/usr    --disable-static --docdir=/usr/share/doc/xz-5.4.1
make -j`nproc`
make check
make install
cd ..
rm -rf xz-5.4.1

tar -xaf zstd-1.5.4.tar.gz
cd zstd-1.5.4
make prefix=/usr -j`nproc`
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a
cd ..
rm -rf zstd-1.5.4

tar -xaf file-5.44.tar.gz
cd file-5.44
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf file-5.44

tar -xaf readline-8.2.tar.gz
cd readline-8.2
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
patch -Np1 -i ../readline-8.2-upstream_fix-1.patch
./configure --prefix=/usr --disable-static --with-curses --docdir=/usr/share/doc/readline-8.2
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2
cd ..
rm -rf readline-8.2

tar -xaf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf m4-1.4.19

tar -xaf bc-6.2.4.tar.xz
cd bc-6.2.4
CC=gcc ./configure --prefix=/usr -G -O3 -r
make -j`nproc`
make test
make install
cd ..
rm -rf bc-6.2.4

tar -xaf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4 --disable-static
make -j`nproc`
make check
make install
ln -sv flex /usr/bin/lex
cd ..
rm -rf flex-2.6.4

tar -xaf tcl8.6.13-src.tar.gz
cd tcl8.6.13
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr --mandir=/usr/share/man
make -j`nproc`
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
    -i pkgs/tdbc1.1.5/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
    -i pkgs/itcl4.2.3/itclConfig.sh
unset SRCDIR
make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
cd ../..
rm -rf tcl8.6.13

tar -xaf expect5.45.4.tar.gz
cd expect5.45.4
./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include
make -j`nproc`
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
cd ..
rm -rf expect5.45.4

tar -xaf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3
mkdir -v build
cd       build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
make check
cd ../..
rm -rf dejagnu-1.6.3

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

tar -xaf mpfr-4.2.0.tar.xz
cd mpfr-4.2.0
sed -e 's/+01,234,567/+1,234,567 /' -e 's/13.10Pd/13Pd/' -i tests/tsprintf.c
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.2.0
make -j`nproc`
make html
make check
make install
make install-html
cd ..
rm -rf mpfr-4.2.0

tar -xaf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.3.1
make -j`nproc`
make html
make check
make install
make install-html
cd ..
rm -rf mpc-1.3.1

tar -xaf attr-2.5.1.tar.gz
cd attr-2.5.1
./configure --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/attr-2.5.1
make -j`nproc`
# make check
make install
cd ..
rm -rf attr-2.5.1

tar -xaf acl-2.3.1.tar.xz
cd acl-2.3.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/acl-2.3.1
make -j`nproc`
make install
cd ..
rm -rf acl-2.3.1

tar -xaf libcap-2.67.tar.xz
cd libcap-2.67
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
cd ..
rm -rf libcap-2.67

tar -xaf shadow-4.13.tar.xz
cd shadow-4.13
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's@#\(SHA_CRYPT_..._ROUNDS 5000\)@\100@'       \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
    -i etc/login.defs
touch /usr/bin/passwd
./configure --sysconfdir=/etc \
            --disable-static  \
            --with-group-name-max-length=32
make -j`nproc`
make exec_prefix=/usr install
make -C man install-man
pwconv
grpconv
mkdir -p /etc/default
useradd -D --gid 999
sed -i '/MAIL/s/yes/no/' /etc/default/useradd
cd ..
rm -rf shadow-4.13

tar -xaf gcc-12.2.0.tar.xz
cd gcc-12.2.0
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir -v build
cd       build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make -j`nproc`
ulimit -s 32768
chown -Rv tester .
# su tester -c "PATH=$PATH make -j`nproc` -k check"
# ../contrib/test_summary
make install
chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/12.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/12.2.0/liblto_plugin.so /usr/lib/bfd-plugins/
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd ../..
rm -rf gcc-12.2.0

tar -xaf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config-0.29.2
make -j`nproc`
make check
make install
cd ..
rm -rf pkg-config-0.29.2

tar -xaf ncurses-6.4.tar.gz
cd ncurses-6.4
./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug --without-normal --with-cxx-shared --enable-pc-files --enable-widec --with-pkg-config-libdir=/usr/lib/pkgconfig
make -j`nproc`
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.4
cp -av dest/* /
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
mkdir -pv      /usr/share/doc/ncurses-6.4
cp -v -R doc/* /usr/share/doc/ncurses-6.4
cd ..
rm -rf ncurses-6.4

tar -xaf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr
make -j`nproc`
make html
chown -Rv tester .
su tester -c "PATH=$PATH make check"
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9
cd ..
rm -rf sed-4.9

tar -xaf psmisc-23.6.tar.xz
cd psmisc-23.6
./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf psmisc-23.6

tar -xaf gettext-0.21.1.tar.xz
cd gettext-0.21.1 
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-0.21.1
make -j`nproc`
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf gettext-0.21.1

tar -xaf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make -j`nproc`
make check
make install
cd ..
rm -rf bison-3.8.2

tar -xaf grep-3.8.tar.xz
cd grep-3.8
sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf grep-3.8

tar -xaf bash-5.2.15.tar.gz
cd bash-5.2.15
./configure --prefix=/usr --without-bash-malloc --with-installed-readline --docdir=/usr/share/doc/bash-5.2.15
make -j`nproc`
make install
cd ..
rm -rf bash-5.2.15

tar -xaf libtool-2.4.7.tar.xz
cd libtool-2.4.7
./configure --prefix=/usr
make -j`nproc`
make install
rm -fv /usr/lib/libltdl.a
cd ..
rm -rf libtool-2.4.7

tar -xaf gdbm-1.23.tar.gz
cd gdbm-1.23
./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make -j`nproc`
make check
make install
cd ..
rm -rf gdbm-1.23

tar -xaf gperf-3.1.tar.gz
cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make -j`nproc`
make -j1 check
make install
cd ..
rm -rf gperf-3.1

tar -xaf expat-2.5.0.tar.xz
cd expat-2.5.0
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-2.5.0
make -j`nproc`
make check
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.5.0
cd ..
rm -rf expat-2.5.0

tar -xaf inetutils-2.4.tar.xz
cd inetutils-2.4
./configure --prefix=/usr --bindir=/usr/bin --localstatedir=/var --disable-logger --disable-whois --disable-rcp --disable-rexec --disable-rlogin --disable-rsh --disable-servers
make -j`nproc`
make check
make install
mv -v /usr/{,s}bin/ifconfig
cd ..
rm -rf inetutils-2.4

tar -xaf less-608.tar.gz
cd less-608
./configure --prefix=/usr --sysconfdir=/etc
make -j`nproc`
make install
cd ..
rm -rf less-608

tar -xaf perl-5.36.0.tar.xz
cd perl-5.36.0
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.36/core_perl      \
             -Darchlib=/usr/lib/perl5/5.36/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.36/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.36/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
make -j`nproc`
make test
make install
unset BUILD_ZLIB BUILD_BZIP2
cd ..
rm -rf perl-5.36.0

tar -xaf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46
perl Makefile.PL
make -j`nproc`
make test
make install
cd ..
rm -rf XML-Parser-2.46

tar -xaf intltool-0.51.0.tar.gz
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make -j`nproc`
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd ..
rm -rf intltool-0.51.0

tar -xaf autoconf-2.71.tar.xz
cd autoconf-2.71
sed -e 's/SECONDS|/&SHLVL|/'              -e '/BASH_ARGV=/a\        /^SHLVL=/ d' -i.orig tests/local.at
./configure --prefix=/usr
make -j`nproc`
make check TESTSUITEFLAGS=-j`nproc`
make install
cd ..
rm -rf autoconf-2.71

tar -xaf automake-1.16.5.tar.xz
cd automake-1.16.5
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
make -j`nproc`
make install
cd ..
rm -rf automake-1.16.5

tar -xaf openssl-3.0.8.tar.gz
cd openssl-3.0.8
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make -j`nproc`
make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.8
cp -vfr doc/* /usr/share/doc/openssl-3.0.8
cd ..
rm -rf openssl-3.0.8

tar -xaf kmod-30.tar.xz
cd kmod-30
./configure --prefix=/usr --sysconfdir=/etc --with-openssl --with-xz --with-zstd --with-zlib
make -j`nproc`
make install
for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done
ln -sfv kmod /usr/bin/lsmod
cd ..
rm -rf kmod-30

tar -xaf elfutils-0.188.tar.bz2
cd elfutils-0.188
./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make -j`nproc`
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
cd ..
rm -rf elfutils-0.188

tar -xaf libffi-3.4.4.tar.gz
cd libffi-3.4.4
./configure --prefix=/usr --disable-static --with-gcc-arch=x86-64
make -j`nproc`
make check
make install
cd ..
rm -rf libffi-3.4.4

tar -xaf Python-3.11.2.tar.xz
cd Python-3.11.2
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --enable-optimizations
make -j`nproc`
make install
cd ..
rm -rf Python-3.11.2

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.11.2/html
tar --strip-components=1 --no-same-owner --no-same-permissions -C /usr/share/doc/python-3.11.2/html -xvf python-3.11.2-docs-html.tar.bz2

tar -xaf wheel-0.38.4.tar.gz
cd wheel-0.38.4
PYTHONPATH=src pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links=dist wheel
cd ..
rm -rf wheel-0.38.4

tar -xaf ninja-1.11.1.tar.gz
cd ninja-1.11.1
python3 configure.py --bootstrap
./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
cd ..
rm -rf ninja-1.11.1

tar -xaf meson-1.0.0.tar.gz
cd meson-1.0.0
pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
cd ..
rm -rf meson-1.0.0

tar -xaf coreutils-9.1.tar.xz
cd coreutils-9.1
patch -Np1 -i ../coreutils-9.1-i18n-1.patch
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --enable-no-install-program=kill,uptime
make -j`nproc`
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd ..
rm -rf coreutils-9.1

tar -xaf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr --disable-static
make -j`nproc`
make check
make docdir=/usr/share/doc/check-0.15.2 install
cd ..
rm -rf check-0.15.2

tar -xaf diffutils-3.9.tar.xz
cd diffutils-3.9
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf diffutils-3.9

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

tar -xaf findutils-4.9.0.tar.xz
cd findutils-4.9.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make -j`nproc`
chown -Rv tester .
su tester -c "PATH=$PATH make check"
make install
cd ..
rm -rf findutils-4.9.0

tar -xaf groff-1.22.4.tar.gz
cd groff-1.22.4
PAGE=A4 ./configure --prefix=/usr
make -j`nproc`
make install
cd ..
rm -rf groff-1.22.4

tar -xaf grub-2.06.tar.xz
cd grub-2.06
unset {C,CPP,CXX,LD}FLAGS
patch -Np1 -i ../grub-2.06-upstream_fixes-1.patch
./configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --disable-werror
make -j`nproc`
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
cd ..
rm -rf grub-2.06

tar -xaf gzip-1.12.tar.xz
cd gzip-1.12
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf gzip-1.12

tar -xaf iproute2-6.1.0.tar.xz
cd iproute2-6.1.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns -j`nproc`
make SBINDIR=/usr/sbin install
mkdir -pv             /usr/share/doc/iproute2-6.1.0
cp -v COPYING README* /usr/share/doc/iproute2-6.1.0
cd ..
rm -rf iproute2-6.1.0

tar -xaf kbd-2.5.1.tar.xz
cd kbd-2.5.1
patch -Np1 -i ../kbd-2.5.1-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make -j`nproc`
make check
make install
mkdir -pv           /usr/share/doc/kbd-2.5.1
cp -R -v docs/doc/* /usr/share/doc/kbd-2.5.1
cd ..
rm -rf kbd-2.5.1

tar -xaf libpipeline-1.5.7.tar.gz
cd libpipeline-1.5.7
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf libpipeline-1.5.7

tar -xaf make-4.4.tar.gz
cd make-4.4
sed -e '/ifdef SIGPIPE/,+2 d' -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' -i src/main.c
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf make-4.4

tar -xaf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf patch-2.7.6

tar -xaf tar-1.34.tar.xz
cd tar-1.34
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make -j`nproc`
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34
cd ..
rm -rf tar-1.34

tar -xaf texinfo-7.0.2.tar.xz
cd texinfo-7.0.2
./configure --prefix=/usr
make -j`nproc`
make check
make install
cd ..
rm -rf texinfo-7.0.2

tar -xaf vim-9.0.1273.tar.xz
cd vim-9.0.1273
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make -j`nproc`
chown -Rv tester .
su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim90/doc /usr/share/doc/vim-9.0.1273
cd ..
rm -rf vim-9.0.1273

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

tar -xaf eudev-3.2.11.tar.gz
cd eudev-3.2.11
sed -i '/udevdir/a udev_dir=${udevdir}' src/udev/udev.pc.in
./configure --prefix=/usr --bindir=/usr/sbin --sysconfdir=/etc --enable-manpages --disable-static
make -j`nproc`
mkdir -pv /usr/lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
# make check
make install
tar -xvf ../udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install
udevadm hwdb --update
cd ..
rm -rf eudev-3.2.11

tar -xaf man-db-2.11.2.tar.xz
cd man-db-2.11.2
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.11.2 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=
make -j`nproc`
make check
make install
cd ..
rm -rf man-db-2.11.2

tar -xaf procps-ng-4.0.2.tar.xz
cd procps-ng-4.0.2
./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-4.0.2 --disable-static --disable-kill
make -j`nproc`
make install
cd ..
rm -rf procps-ng-4.0.2

tar -xaf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir \
            --docdir=/usr/share/doc/util-linux-2.38.1
make -j`nproc`
make install
cd ..
rm -rf util-linux-2.38.1

tar -xaf e2fsprogs-1.47.0.tar.gz
cd e2fsprogs-1.47.0
mkdir -v build
cd       build
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make -j`nproc`
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
cd ../..
rm -rf e2fsprogs-1.47.0

tar -xaf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
make -j`nproc`
make BINDIR=/sbin install
cd ..
rm -rf sysklogd-1.5.1

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

tar -xaf sysvinit-3.06.tar.xz
cd sysvinit-3.06
patch -Np1 -i ../sysvinit-3.06-consolidated-1.patch
make -j`nproc`
make install
cd ..
rm -rf sysvinit-3.06

rm -rf /tmp/*
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester

tar -xaf lfs-bootscripts-20230101.tar.xz
cd lfs-bootscripts-20230101
make install
cd ..
rm -rf lfs-bootscripts-20230101

echo "mylfs" > /etc/hostname

cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

FONT="lat1-16 -m 8859-1"

# End /etc/sysconfig/console
EOF

cat > /etc/profile << "EOF"
# Begin /etc/profile

export LANG=en_US.UTF-8

# End /etc/profile
EOF

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

UUID=ReplaceMeWithTheFileSystemUUID     /            ext4     defaults            1     1
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm     tmpfs    nosuid,nodev        0     0

# End /etc/fstab
EOF

tar -xaf linux-6.1.11.tar.xz
cd linux-6.1.11
make mrproper
cp ../../linux_config .config
make -j`nproc`
make modules_install
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.1.11-lfs-11.3
cp -iv System.map /boot/System.map-6.1.11
install -d /usr/share/doc/linux-6.1.11
cp -r Documentation/* /usr/share/doc/linux-6.1.11
cd ..
rm -rf linux-6.1.11

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

echo root:password | chpasswd
