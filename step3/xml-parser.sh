tar -xaf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46
perl Makefile.PL
make -j`nproc`
make test
make install
cd ..
rm -rf XML-Parser-2.46
