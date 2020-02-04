# 6. pkg-config配置


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


/vita/scripts/gen-pkgconfig.sh :

```
#!/bin/bash

set -e

source functions

cat > /vita/cross-tool/bin/pkg-config << EOF
#!/bin/bash
HOST_PKG_CFG=/usr/bin/pkg-config

if [ ! $SYSROOT ];then
	echo "Please make sure you are in cross-comile environment!"
	exit 1
fi

$HOST_PKG_CFG --exists $*
if [ $? -ne 0 ];then
	exit 1
fi

if $HOST_PKG_CFG $* | sed -e "s/-I/-I\/vita\/sysroot/g; \
	s/-L/-L\/vita\/sysroot/g"
then
	exit 0
else
	exit 1
fi
EOF

chmod a+x /vita/cross-tool/bin/pkg-config
ls -alh  /vita/cross-tool/bin/pkg-config
find $SYSROOT -name "*.la" -exec rm -f '{}' \;
echogreen "### finish pkg-config generate"
```
