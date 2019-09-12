#!/bin/bash 

unset LANG
export HOST=i686-pc-linux-gnu
export BUILD=$HOST
export TARGET=i686-none-linux-gnu
export CROSS_TOOL=/vita/cross-tool
export CROSS_GCC_TMP=/vita/cross-gcc-tmp
export SYSROOT=/vita/sysroot
PATH=$CROSS_TOOL/bin:$CROSS_GCC_TMP/bin:/sbin/:/usr/sbin:$PATH

CORES=`grep processor /proc/cpuinfo |wc -l`
SPEEDUP=" -j ${CORES}"


function basicenv()
{
	unset LANG
	export HOST=i686-pc-linux-gnu
	export BUILD=$HOST
	export TARGET=i686-none-linux-gnu
	export CROSS_TOOL=/vita/cross-tool
	export CROSS_GCC_TMP=/vita/cross-gcc-tmp
	export SYSROOT=/vita/sysroot
	PATH=$CROSS_TOOL/bin:$CROSS_GCC_TMP/bin:/sbin/:/usr/sbin:$PATH
	

	grep 'unset LANG' ~/.bashrc || echo 'unset LANG' >> ~/.bashrc
	grep 'export HOST=i686-pc-linux-gnu' ~/.bashrc || echo 'export HOST=i686-pc-linux-gnu' >> ~/.bashrc
	grep 'export BUILD=$HOST' ~/.bashrc || echo 'export BUILD=$HOST' >> ~/.bashrc
	grep 'export TARGET=i686-none-linux-gnu' ~/.bashrc || echo 'export TARGET=i686-none-linux-gnu' >> ~/.bashrc
	grep 'export CROSS_TOOL=/vita/cross-tool' ~/.bashrc || echo 'export CROSS_TOOL=/vita/cross-tool' >> ~/.bashrc
	grep 'export CROSS_GCC_TMP=/vita/cross-gcc-tmp' ~/.bashrc || echo 'export CROSS_GCC_TMP=/vita/cross-gcc-tmp' >> ~/.bashrc
	grep 'export SYSROOT=/vita/sysroot' ~/.bashrc || echo 'export SYSROOT=/vita/sysroot' >> ~/.bashrc
	grep 'PATH=$CROSS_TOOL/bin:$CROSS_GCC_TMP/bin:/sbin/:/usr/sbin:$PATH' ~/.bashrc || echo 'PATH=$CROSS_TOOL/bin:$CROSS_GCC_TMP/bin:/sbin/:/usr/sbin:$PATH' >> ~/.bashrc

	echo  -e "\e[32m\e[1m ========== finish basic environment build =================================  \e[0m"
}

function checkout(){
	if [ ${PIPESTATUS[0]} -ne 0 ];then
		echo  -e "\e[31m\e[1m ===========================================  \e[0m"
		echo  -e "\e[31m\e[1m  Error!please checkout it. [$1]  \e[0m"
		echo  -e "\e[31m\e[1m ===========================================  \e[0m"
		exit 1
	fi
}

function aptinstall(){
	apt-get update
#	apt-get upgrade -y
	apt-get install  xorg-dev xserver-xephyr lrzsz \
			 libgtk-3-dev 	openssh-server \
			 libncurses5-dev build-essential \
			 texinfo autoconf gawk tree g++ \
			 m4 gcc-multilib htop libtool  -y
	checkout apt-get
	echo  -e "\e[32m\e[1m ========== finish apt install  =================================  \e[0m"
}

function binutils(){
	cd /vita/build

	test -d /vita/build/binutils-2.23.1 && /bin/rm -rf binutils-2.23.1
	tar -xf ../source/binutils-2.23.1.tar.bz2 
	checkout log.xf.binutils

	test -d binutils-build && /bin/rm -rf binutils-build
	mkdir binutils-build && cd binutils-build


	../binutils-2.23.1/configure --prefix=$CROSS_TOOL --target=$TARGET --with-sysroot=$SYSROOT  2>&1 | tee log.configure.binutils
	checkout log.configure.binutils

	make ${SPEEDUP}  2>&1 | tee log.make.binutils
	checkout log.make.binutils

	make ${SPEEDUP} install 2>&1 | tee log.makeinstall.binutils
	checkout log.makeinstall.binutils

	echo  -e "\e[32m\e[1m ========== finish binutils build =================================  \e[0m"
}

function gcc(){

	cd /vita/build/

	test -d  gcc-4.7.2 && /bin/rm -rf gcc-4.7.2 
	tar -xf ../source/gcc-4.7.2.tar.bz2 
	checkout log.xf.gcc

	cd gcc-4.7.2/
	tar -xf ../../source/gmp-5.0.5.tar.bz2 
	checkout log.xf.gmp
	test -d gmp &&  /bin/rm -rf gmp
	/bin/mv -f  gmp-5.0.5 gmp

	tar -xf ../../source/mpfr-3.1.1.tar.bz2  
	checkout log.xf.mpfr
	test -d mpfr && /bin/rm -rf mpfr
	/bin/mv -f  mpfr-3.1.1 mpfr

	tar -xf ../../source/mpc-1.0.1.tar.gz 
	checkout log.xf.mpc
	test -d mpc && /bin/rm -rf mpc
	/bin/mv -f  mpc-1.0.1 mpc

	test -d /vita/build/gcc-build && /bin/rm -rf /vita/build/gcc-build 
	mkdir /vita/build/gcc-build  && cd /vita/build/gcc-build

	../gcc-4.7.2/configure  --prefix=$CROSS_GCC_TMP \
				--target=$TARGET \
				--with-sysroot=$SYSROOT \
				--with-newlib \
				--enable-languages=c \
				--with-mpfr-include=/vita/build/gcc-4.7.2/mpfr/src \
				--with-mpfr-lib=/vita/build/gcc-build/mpfr/src/.libs \
				--disable-shared --disable-threads \
				--disable-decimal-float --disable-libquadmath \
				--disable-libmudflap --disable-libgomp \
				--disable-nls --disable-libssp 2>&1 | tee log.configure.gcc
	checkout log.configure.gcc

	make ${SPEEDUP} 2>&1 | tee log.make.gcc
	checkout log.make.gcc

	make ${SPEEDUP} install 2>&1 | tee log.makeinstall.gcc
	checkout log.makeinstall.gcc


	cd /vita/cross-gcc-tmp
	ln -sfv libgcc.a lib/gcc/i686-none-linux-gnu/4.7.2/libgcc_eh.a  2>&1 | tee log.ln.libgcc
	checkout log.ln.libgcc

	echo  -e "\e[32m\e[1m =========== finish gcc build =====================================  \e[0m"
}

function kernelheaders(){

	cd /vita/build
	test -d linux-3.7.4 && /bin/rm -rf linux-3.7.4
	tar -xf ../source/linux-3.7.4.tar.xz 
	checkout log.xf.linux

	cd /vita/build/linux-3.7.4
	make mrproper 2>&1 | tee log.mrproper
	checkout log.mrproper

	make ARCH=i386 headers_check 2>&1  | tee log.make.headers_check
	checkout log.make.headers_check

	make defconfig

	make ARCH=i386 INSTALL_HDR_PATH=$SYSROOT/usr/  headers_install ${SPEEDUP} 2>&1 | tee log.make.headers


	echo  -e "\e[32m\e[1m ========== finish kernel headers build ===========================  \e[0m"

}

function glibc(){

	cd /vita/build
	
	test -d glibc-2.15 && /bin/rm -rf glibc-2.15
	tar -xf ../source/glibc-2.15.tar.xz 
	checkout log.xf.glibc

	cd glibc-2.15
	patch -p1 < ../../source/glibc-2.15-cpuid.patch 2>&1 | tee log.glibc.patch.cpuid
	checkout log.glibc.patch.cpuid
	patch -p1 < ../../source/glibc-2.15-s_frexp.patch 2>&1 | tee log.glibc.patch.frexp
	checkout log.glibc.patch.frexp
	

	mkdir -p /vita/build/glibc_build
	cd /vita/build/glibc_build
	echo $TARGET
	echo $SYSROOT
	../glibc-2.15/configure --prefix=/usr --host=$TARGET \
				--enable-kernel=3.7.4 --enable-add-ons \
				--with-headers=$SYSROOT/usr/include \
				libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes \
				libc_cv_ctors_header=yes 2>&1 | tee log.configure.glibc
	checkout log.configure.glibc

	make ${SPEEDUP}  2>&1 | tee log.make.glibc
	checkout log.make.glibc

	make ${SPEEDUP} install_root=$SYSROOT install 2>&1 | tee log.makeinstall.glibc
	checkout log.makeinstall.glibc
	echo  -e "\e[32m\e[1m ========== finish glibc build =====================================  \e[0m"
}

function fullcompiler(){
	cd /vita/build/gcc-build
	/bin/rm -rf /vita/build/gcc-build/*
	../gcc-4.7.2/configure \
		--prefix=$CROSS_TOOL --target=$TARGET \
		--with-sysroot=$SYSROOT \
		--with-mpfr-include=/vita/build/gcc-4.7.2/mpfr/src \
		--with-mpfr-lib=/vita/build/gcc-build/mpfr/src/.libs \
		--enable-languages=c,c++ --enable-threads=posix 2>&1 | tee log.fullcompiler
	checkout log.fullcompiler

	make ${SPEEDUP} 2>&1 | tee log.make.fullcompiler
	checkout log.make.fullcompiler

	make ${SPEEDUP} install 2>&1 | tee log.makeinstall.fullcompiler
	checkout log.makeinstall.fullcompiler

	echo  -e "\e[32m\e[1m ========== finish fullcompiler build =============================  \e[0m"
}

function defineenv(){
	
	export CC="$TARGET-gcc"
	export CXX="$TARGET-g++"
	export AR="$TARGET-ar"
	export AS="$TARGET-as"
	export RANLIB="$TARGET-ranlib"
	export LD="$TARGET-ld"
	export STRIP="$TARGET-strip"

	export DESTDIR=$SYSROOT
	unset PKG_CONFIG_PATH
	export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:SYSROOT/usr/share/pkgconfig	

	grep 'export CC="$TARGET-gcc"' ~/.bashrc || echo 'export CC="$TARGET-gcc"' >> ~/.bashrc
	grep 'export CXX="$TARGET-g++"' ~/.bashrc || echo 'export CXX="$TARGET-g++"' >> ~/.bashrc
	grep 'export AR="$TARGET-ar"' ~/.bashrc || echo 'export AR="$TARGET-ar"' >> ~/.bashrc
	grep 'export AS="$TARGET-as"' ~/.bashrc || echo 'export AS="$TARGET-as"' >> ~/.bashrc
	grep 'export RANLIB="$TARGET-ranlib"' ~/.bashrc || echo 'export RANLIB="$TARGET-ranlib"' >> ~/.bashrc
	grep 'export LD="$TARGET-ld"' ~/.bashrc || echo 'export LD="$TARGET-ld"' >> ~/.bashrc
	grep 'export STRIP="$TARGET-strip"' ~/.bashrc || echo 'export STRIP="$TARGET-strip"' >> ~/.bashrc
	grep 'export DESTDIR=$SYSROOT' ~/.bashrc || echo 'export DESTDIR=$SYSROOT' >> ~/.bashrc
	grep 'unset PKG_CONFIG_PATH' ~/.bashrc || echo 'unset PKG_CONFIG_PATH' >> ~/.bashrc
	grep 'export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:SYSROOT/usr/share/pkgconfig' ~/.bashrc || echo 'export PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig:SYSROOT/usr/share/pkgconfig' >> ~/.bashrc

	echo  -e "\e[32m\e[1m ========== finish define environment  =============================  \e[0m"
}

function pkgconfig(){

	FILE=/vita/cross-tool/bin/pkg-config
	/bin/cat << EOF > ${FILE}
#!/bin/bash
HOST_PKG_CFG=/usr/bin/pkg-config

if [ ! \$SYSROOT ];then
	echo "Please make sure you are in cross-comile environment!"
	exit 1
fi

\$HOST_PKG_CFG --exists \$*
if [ \$? -ne 0 ];then
	exit 1
fi

if \$HOST_PKG_CFG \$* | sed -e "s/-I/-I\/vita\/sysroot/g; \\
	s/-L/-L\/vita\/sysroot/g"
then
	exit 0
else
	exit 1
fi
EOF
	chmod a+x ${FILE}
	
	echo  -e "\e[32m\e[1m ========== finish pkg-config =============================  \e[0m"
}

function main()
{
	#basicenv
	#aptinstall
	#binutils
	#gcc
	#kernelheaders
	#glibc
	fullcompiler
	defineenv
	pkgconfig
}

main
