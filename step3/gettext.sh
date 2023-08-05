tar -xaf gettext-0.21.1.tar.xz
cd gettext-0.21.1
./configure --disable-shared
make -j`nproc`
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
cd ..
rm -rf gettext-0.21.1
