# 4. glibc编译


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


/vita/scripts/mk-glibc.sh :

```
#!/bin/bash

set -e

source functions

function glibc(){

	cd /vita/build

	test -d glibc-2.15 && /bin/rm -rf glibc-2.15
	tar -xf ../source/glibc-2.15.tar.xz

	cd glibc-2.15
	patch -p1 < ../../source/glibc-2.15-cpuid.patch 2>&1 | tee log.glibc.patch.cpuid
	patch -p1 < ../../source/glibc-2.15-s_frexp.patch 2>&1 | tee log.glibc.patch.frexp


	mkdir -p /vita/build/glibc_build
	cd /vita/build/glibc_build
	echogreen $TARGET
	echogreen $SYSROOT
	../glibc-2.15/configure --prefix=/usr --host=$TARGET \
				--enable-kernel=3.7.4 --enable-add-ons \
				--with-headers=$SYSROOT/usr/include \
				libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes \
				libc_cv_ctors_header=yes 2>&1 | tee log.configure.glibc

	make ${SPEEDUP}  2>&1 | tee log.make.glibc

	make ${SPEEDUP} install_root=$SYSROOT install 2>&1 | tee log.makeinstall.glibc
	echo "ls $SYSROOT/lib"
	ls $SYSROOT/lib
	echogreen "### finished glibc build"
}

glibc
```
