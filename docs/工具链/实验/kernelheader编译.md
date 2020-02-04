# 3. kernelheader编译


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


/vita/scripts/mk-kernelhead.sh :

```
#!/bin/bash

set -e

source functions

function kernelheaders(){
	cd /vita/build
	test -d linux-3.7.4 && /bin/rm -rf linux-3.7.4
	tar -xf ../source/linux-3.7.4.tar.xz

	cd /vita/build/linux-3.7.4
	make mrproper 2>&1 | tee log.mrproper

	make ARCH=i386 headers_check 2>&1  | tee log.make.headers_check

	make defconfig

	make ARCH=i386 INSTALL_HDR_PATH=$SYSROOT/usr/  headers_install ${SPEEDUP} 2>&1 | tee log.make.headers

	echogreen "ls $SYSROOT/usr/include"
	ls $SYSROOT/usr/include
	echogreen "### finish kernel head build"

}

kernelheaders
```
