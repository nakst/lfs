tar -xaf zstd-1.5.4.tar.gz
cd zstd-1.5.4
make prefix=/usr -j`nproc`
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a
cd ..
rm -rf zstd-1.5.4
