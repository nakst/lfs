tar -xaf wheel-0.38.4.tar.gz
cd wheel-0.38.4
PYTHONPATH=src pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links=dist wheel
cd ..
rm -rf wheel-0.38.4
