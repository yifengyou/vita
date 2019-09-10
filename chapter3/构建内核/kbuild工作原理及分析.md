# kbuild工作原理及分析

![1538273374727.png](image/1538273374727.png)

* 每个平台下都有一个 Kconfig, Kconfig又通过 source 构建出一个 Kconfig 树
* 当make %config 时， scripts/kconfig 中的工具程序 conf/mconf/qconf 负责对 Kconfig 的解
析。
