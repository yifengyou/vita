# 5. 完整gcc编译

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


/vita/scripts/mk-fullgcc.sh :

```
#!/bin/bash

set -e

source functions

function fullgcc(){

	cd /vita/build/

	test -d  gcc-4.7.2 && /bin/rm -rf gcc-4.7.2
	tar -xf ../source/gcc-4.7.2.tar.bz2

	cd gcc-4.7.2/

	tar -xf ../../source/gmp-5.0.5.tar.bz2
	test -d gmp &&  /bin/rm -rf gmp
	/bin/mv -f  gmp-5.0.5 gmp

	tar -xf ../../source/mpfr-3.1.1.tar.bz2  
	test -d mpfr && /bin/rm -rf mpfr
	/bin/mv -f  mpfr-3.1.1 mpfr

	tar -xf ../../source/mpc-1.0.1.tar.gz
	test -d mpc && /bin/rm -rf mpc
	/bin/mv -f  mpc-1.0.1 mpc

	cd /vita/build/

        test -d fullgcc-build && /bin/rm -rf fullgcc-build
	mkdir fullgcc-build && cd fullgcc-build

        ../gcc-4.7.2/configure \
                --prefix=$CROSS_TOOL --target=$TARGET \
                --with-sysroot=$SYSROOT \
                --with-mpfr-include=/vita/build/gcc-4.7.2/mpfr/src \
                --with-mpfr-lib=/vita/build/fullgcc-build/mpfr/src/.libs \
                --enable-languages=c,c++ --enable-threads=posix 2>&1 | tee log.fullcompiler

        make ${SPEEDUP} 2>&1 | tee log.make.fullcompiler

        make ${SPEEDUP} install 2>&1 | tee log.makeinstall.fullcompiler

	echogreen "### finish full gcc build"
}


fullgcc
```
