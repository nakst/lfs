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
