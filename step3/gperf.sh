tar -xaf gperf-3.1.tar.gz
cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make -j`nproc`
make -j1 check
make install
cd ..
rm -rf gperf-3.1
