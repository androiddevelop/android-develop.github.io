---
layout: post
comments: true
title: 'Andorid开发调试之run-as'
date: '2019-09-10'
header-img: "img/post-bg-android.jpg"
tags:
     - android
author: 'Codeboy'
---

### 前言

Android开发中，经常会将一些文件放在内部目录中，也即`/data/data/pacakge_id`中，db文件也在该目录中 ，在非root的手机中，我们无法直接访问` /data/data` 下的文件，调试起来非常的不方便，解决的办法有几种：

1. 找一台root的手机，想看什么看什么

2. 断点调试，可以稍微麻烦的看到本应用的目录及文件

3. run-as命令

本文来讲解一下`run-as`。

### run-as

`run-as` 命令来获取debug应用的私有数据，在对debug包测试的时候，使用该命令可以切换用户到系统分配给对应debug应用的uid，下面以我的一个测试应用`me.codeboy.test` 为例看一下:

```shell
➜ ~ adb shell
chiron:/ $ whoami
shell

chiron:/ $ ls /data/data/me.codeboy.test
ls: /data/data/me.codeboy.test: Permission denied

1|chiron:/ $ run-as me.codeboy.test
chiron:/data/data/me.codeboy.test $ ls
cache code_cache shared_prefs 

chiron:/data/data/me.codeboy.test $ whoami
u0_a279
```

可以看出在默认的shell环境下，用户身份是`shell`，无法查看应用的私有数据，运行 `run-as` 后，身份切换了 `u0_a279`, 这个用户其实是测试应用的uid，所以可以自由的访问其私有目录。

Android中一个应用有一个uid，可以通过一下方式获取:

```java
try {
  		PackageManager pm = getPackageManager();
  		ApplicationInfo ai = pm.getApplicationInfo("me.codeboy.test", 0);
  		Toast.makeText(MainActivity.this, Integer.toString(ai.uid,10), Toast.LENGTH_SHORT).show();
    } catch (PackageManager.NameNotFoundException e) {
}
```

执行后，输出的结果是10279。

每个Android应用程序的u0_axxx都是不一样的，同时UID是从10000开始，u0_a后面的数字加上10000所得的值，既是UID，这个和测试应用的输出也非常的吻合，`u0_a279` 和 `10279`。

### 小结

`run-as` 让可以在非root的手机上查看应用的私有目录，对开发调试来说非常的方便。




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
