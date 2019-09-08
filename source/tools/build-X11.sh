#!/bin/bash

BUILD_DIR=/vita/build
SRC_DIR=/vita/source
X_DIR=/vita/source/X7.7

X_DEPS="pixman freetype"
X_PROTOS="xproto xextproto kbproto inputproto xcb-proto
       glproto dri2proto fixesproto damageproto 
       xcmiscproto bigreqsproto randrproto renderproto
       fontsproto videoproto compositeproto resourceproto
       xf86dgaproto"
X_LIBS="xtrans libpthread-stubs libXau libxcb libX11
       libpciaccess libXext libXfixes libXdamage libxkbfile
       libfontenc libXfont"
X_APPS_DATA="xkbcomp xkeyboard-config"
X_DRVS="xf86-video-vesa xf86-input-evdev xf86-video-intel"

pushd $BUILD_DIR

### build M4 macros

rm -rf $BUILD_DIR/util-macros*
tar xvf $X_DIR/util-macros* || exit 1
pushd util-macros*
./configure --prefix=/usr || exit 1
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

### build X11 protos & extensions

for p in $X_PROTOS ;
do
    rm -rf $BUILD_DIR/$p*
    tar xvf $X_DIR/$p* || exit 1
    pushd $p*
    ./configure --prefix=/usr || exit 1
    make install || exit 1
    popd
done

### build libs on which X11 depends

for p in $X_DEPS ;
do
    rm -rf $BUILD_DIR/$p*
    tar xvf $SRC_DIR/$p* || exit 1
    pushd $p*
    ./configure --prefix=/usr || exit 1
    make || exit 1
    make install || exit 1
    find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
    popd
done

### build X11 libs & apps & data

for p in $X_LIBS $X_APPS_DATA;
do
    tar xvf $X_DIR/$p* || exit 1
    pushd $p*
    ./configure --prefix=/usr || exit 1
    make || exit 1
    make install || exit 1
    find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
    popd
done

### build libdrm

rm -rf $BUILD_DIR/libdrm*
tar xvf $SRC_DIR/libdrm* || exit 1
pushd libdrm*
./configure --prefix=/usr || exit
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

### build mesa

# expat. xml parser on which mesa depends.
rm -rf $BUILD_DIR/expat*
tar xvf $SRC_DIR/expat* || exit 1
pushd expat*
./configure --prefix=/usr || exit
make || exit 1
make install DESTDIR=$SYSROOT || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

# mesa
rm -rf $BUILD_DIR/Mesa*
tar xvf $SRC_DIR/Mesa* || exit 1
pushd Mesa*
./configure --prefix=/usr \
    --with-dri-drivers=swrast,i915,i965 \
    --disable-gallium-llvm --without-gallium-drivers || exit 1
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
popd

### build X11 server

rm -rf $BUILD_DIR/xorg-server*
tar xvf $X_DIR/xorg-server*
pushd xorg-server*
./configure --prefix=/usr --enable-dri2 --disable-dri \
    --disable-xnest --disable-xephyr --disable-xvfb \
    --disable-record --disable-xinerama --disable-screensaver \
    --with-xkb-output=/var/lib/xkb --with-log-dir=/var/log || exit 1
make || exit 1
make install || exit 1
find $SYSROOT -name "*.la" -exec rm -f '{}' \;
popd

### build X drivers

for p in $X_DRVS ;
do
    rm -rf $BUILD_DIR/$p*
    tar xvf $X_DIR/$p* || exit 1
    pushd $p*
    ./configure --prefix=/usr || exit 1
    make || exit 1
    make install || exit 1
    find $SYSROOT -name "*.la" -exec rm -f '{}' \; || exit 1
    popd
done

popd # $BUILD_DIR

