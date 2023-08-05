tar -xaf procps-ng-4.0.2.tar.xz
cd procps-ng-4.0.2
./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-4.0.2 --disable-static --disable-kill
make -j`nproc`
make install
cd ..
rm -rf procps-ng-4.0.2
