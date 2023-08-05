tar -xaf man-pages-6.03.tar.xz
cd man-pages-6.03
make prefix=/usr install
cd ..
rm -rf man-pages-6.03
