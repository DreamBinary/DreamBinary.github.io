---
title: Clion + Keil5 写stm32
categories: [stm]
tags: [stm]
description: 配置Clion用于stm32开发
---


---
# 前言
最近在学 stm32，使用 Kei5 写代码十分难受，代码提示差，看源码复杂，甚至括号匹配都没有。就想着 JetBrains 家的东西能不能用，就找的了稚晖君的[《配置CLion用于STM32开发【优雅の嵌入式开发】》](https://www.bilibili.com/read/cv6308000)，配置之后又想用 stm32 的原生库不想用HAL库，因为跟着江协科技学起来方便。折腾一番，发现能编译，能烧录，但 stm32 就是跑不起来。最后想了一个折中的办法，用 Clion 来写代码，用 Keil5 来烧录。 

---
# 一、现有条件
根据稚晖君的教程会得到以下目录：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/5f7c78843de26ae5ef93aa745a8a7559.png)

点开 CMakeLists.txt，可以看到下面几行：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/ebb67e1a7dc845be0c4c6028bffaf66a.png)

只有这几行配置好，CMake 才能正确打包，Clion 才能提供代码提示等等。
可以点开 Core 文件夹看看里面的东西：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/c6c4b84b4dff325f1d25277af1f8dba4.png)

这样有放置 .h 文件的 Inc 文件夹和放置 .c 文件的 Src 文件夹，这就明白 include_directories 的作用了。

---
# 二、Clion 和 Keil 结合
## 1. Keil 目录
正常的 Keil 目录是这样的：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/878bae1712f8fcb346bcf6cacd812cb2.png)

## 2. 加入 Clion 生成文件
直接 Copy 以下文件(不用 Core 和 Drivers 目录)到上面 Keil 目录：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/0d331028b88c76f7b12f3536a39239b2.png)

得到这样一个目录：
![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/8634266f4cbf7e47b94c80ab11551d5c.png)
## 3. 复制文件
仿照 Core 目录写一个 Clion 目录：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/0a64b052de0ede2e6c3cfc18cfbe4a25.png)
这个目录用于 Clion 写代码的时候使用，接下来将原来 Keil 目录中所有的 .h 和 .c文件复制到 Inc 和 Src 两个文件夹。
这里我用 python 写了两个个小脚本编成了 copy2clion.exe 和 link2clion，前者仅仅是复制，后者用使用了硬链接，在 Clion 中修改文件可以同步到源文件，方便在 Clion 中编辑在 Keil 中编译。.py 和 .exe 都在 [Github](https://github.com/DreamBinary/stm32/tree/master/_Template_Clion_Keil_Init)了，有需要可以直接修改 .py 文件，然后用 auto-py-to-exe(超好用超好用)编译成 exe。
修改 CMakeLists.txt 文件如下：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/267819fca2831ddad4195653a43e819f.png)

添加 User/main.c 文件方便直接编写 main.c 文件。

## 4. 构建项目
点击 Clion 上方的小锤子构建一下整个项目，点开 main.c 可以看到已经可以有代码提示和点击看源码的功能了:
![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/c69eee0f0de4815449a9a8bcfdefaedb.png)

点击小锤子如果出现以下错误：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/8067a853ca60bb32bdc22016b7b3cea6.png)

需要在 stm32f10x.h 添加一行代码，原因报错也说了：

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/c4e2a69a6770f9e22df453c3c3a6cc3e.png)
## 5. 编译烧录
程序的编译和烧录就要用 Keil 来执行了，所有操作都和之前一样，不过在 Clion 中有新建项目的时候，在 Keil 也要添加一下不然会报错。




---
# 最后
希望大家有个良好的 stm32 学习体验。
