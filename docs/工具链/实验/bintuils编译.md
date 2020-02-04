# 1. bintuils编译

## 编译脚本

/vita/scripts/functions :

```
#!/bin/bash

unset LANG
export HOST=i686-pc-linux-gnu
export BUILD=$HOST
export TARGET=i686-none-linux-gnu
export CROSS_TOOL=/vita/cross-tool
export CROSS_GCC_TMP=/vita/cross-gcc-tmp
export SYSROOT=/vita/sysroot
PATH=$CROSS_TOOL/bin:$CROSS_GCC_TMP/bin:/sbin/:/usr/sbin:$PATH
unset PKG_CONFIG_PATH
export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:SYSROOT/usr/share/pkgconfig
CORES=`grep processor /proc/cpuinfo |wc -l`
SPEEDUP=" -j ${CORES}"

echogreen(){
	echo -e "\033[32m\033[1m$*\033[0m"
	return 0
}

echored(){
	echo -e "\033[31m\033[1m$*\033[0m"
	return 0
}

echoblue(){
	echo -e "\033[34m\033[1m$*\033[0m"
	return 0
}
```


/vita/scripts/mk-binutils :

```
#!/bin/bash

set -e

source functions

function binutils(){
	cd /vita/build

	test -d /vita/build/binutils-2.23.1 && /bin/rm -rf binutils-2.23.1
	tar -xf ../source/binutils-2.23.1.tar.bz2

	test -d binutils-build && /bin/rm -rf binutils-build
	mkdir binutils-build && cd binutils-build

	../binutils-2.23.1/configure --prefix=$CROSS_TOOL --target=$TARGET --with-sysroot=$SYSROOT  2>&1 | tee log.configure.binutils

	make ${SPEEDUP}  2>&1 | tee log.make.binutils

	make ${SPEEDUP} install 2>&1 | tee log.makeinstall.binutils

	echogreen "ls $CROSS_TOOL/i686-none-linux-gnu/lib/ldscripts"
	ls $CROSS_TOOL/i686-none-linux-gnu/lib/ldscripts
	echogreen "ls $CROSS_TOOL/i686-none-linux-gnu/bin"
	ls $CROSS_TOOL/i686-none-linux-gnu/bin
	echogreen "ls $CROSS_TOOL/bin"
	ls $CROSS_TOOL/bin
	echogreen "### finish binutils build"
}

binutils

```
