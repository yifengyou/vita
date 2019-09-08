#!/bin/bash

BUILD_DIR=/vita/build
SRC_DIR=/vita/source
X_DIR=/vita/source/X7.7

LIBS="libffi glib- atk libpng"

pushd $BUILD_DIR

for p in $LIBS ;
do
    rm -rf $BUILD_DIR/$p*
    tar xvf $SRC_DIR/$p* || exit 1
    pushd $p*
    ./configure --prefix=/usr || exit 1
    make install || exit 1
    find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
    popd
done

# libXi

rm -rf $BUILD_DIR/libXi*
tar xvf $X_DIR/libXi* || exit 1
pushd libXi*
./configure --prefix=/usr --sysconfdir=/etc || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd


# gdk pixbuf

rm -rf $BUILD_DIR/gdk-pixbuf*
tar xvf $SRC_DIR/gdk-pixbuf*tar* || exit 1
pushd gdk-pixbuf*
patch -p1 < ../../source/gdk-pixbuf-2.26.3-disable-test.patch || exit 1
./configure --prefix=/usr --without-libtiff --without-libjpeg || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

# fontconfig

rm -rf $BUILD_DIR/fontconfig*
tar xvf $SRC_DIR/fontconfig* || exit 1
pushd fontconfig*
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    --disable-docs --without-add-fonts || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

# cairo 

rm -rf $BUILD_DIR/cairo*
tar xvf $SRC_DIR/cairo* || exit 1
pushd cairo*
./configure --prefix=/usr || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

# pango

rm -rf $BUILD_DIR/pango*
tar xvf $SRC_DIR/pango* || exit 1
pushd pango*
./configure --prefix=/usr --sysconfdir=/etc || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd


# gtk

rm -rf $BUILD_DIR/gtk*
tar xvf $SRC_DIR/gtk* || exit 1
pushd gtk*
./configure --prefix=/usr --sysconfdir=/etc || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

popd # $BUILD_DIR
