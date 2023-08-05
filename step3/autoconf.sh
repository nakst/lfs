tar -xaf autoconf-2.71.tar.xz
cd autoconf-2.71
sed -e 's/SECONDS|/&SHLVL|/'              -e '/BASH_ARGV=/a\        /^SHLVL=/ d' -i.orig tests/local.at
./configure --prefix=/usr
make -j`nproc`
make check TESTSUITEFLAGS=-j`nproc`
make install
cd ..
rm -rf autoconf-2.71
