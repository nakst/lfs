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
