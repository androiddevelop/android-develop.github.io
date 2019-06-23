---
layout: post
comments: true
title: 'Zip几点小知识'
date: '2019-03-20'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---

### 问题来源

1. zip怎么加速解压速度？
2. 相同文件分别压缩为 <code>a.zip</code>  和 <code>b.zip</code> 后，计算出的md5一样么？原因是？
3. zip文件的时间是怎么计算的？ (二进制上是怎么计算的)

### zip怎么加速解压速度

为什么会有这个问题，源于近来项目中有一些cache包下发到手机中，需要解压，但是在一些中低端手机上，解压速度非常的慢，在一些算法求解中，常见的方式是使用空间换时间，zip中可行么？答案是可行的，看一下zip的几个参数：


```nohighlight
-0   store only 不压缩
-1   compress faster 最快压缩，压缩率最差。
-9   compress better 最大压缩，压缩率最佳。
```

0-9之间代表不同的压缩率，可以使用 `-0` 参数进行无损压缩，换句话说，即简单的将文件进行拼接即可。 对一个6.4M的js、css资源按照0、1、9压缩后，大小分别是5.7M、2.4M、2.1M，在手机解压速度测试中时间大幅度减少。


### 相同文件压缩后的zip的md5值是否相同

一直有个疑问，对同一个文件进行压缩，一次压缩结果为 `1.zip`, 另外一次是 `2.zip`, 计算两个文件的md5，会是一样的么？ 先说一下结果，可能一样，也可能不一样，首先文件名对md5的结果没有影响，然后前后手动压缩一个文本文件，查看两个文件的二进制，发现只有一个字节不同，第一感觉大家应该都会想到是时间问题，确实是时间的改变造成了2个文件的差异，zip结构中有个 `Extra Filed`，里面记录了文件上次修改和上次访问时间，当对文件进行第一次压缩时，文件的访问时间可能会被修改，因为该时间计算单位是秒，所以在脚本执行的情况下，会出现以下结果：

```bash
➜  zip ./a.sh 
adding: hello.txt (stored 0%)
MD5 (h1.zip) = a277a7f05ca3cba3eb119424068aad95
adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = cd8924673f41e81b585a809df8e6b714
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = 5b69e56cc533d19c14c1aa234bd7d6e3
  adding: hello.txt (stored 0%)
MD5 (h1.zip) = 5b69e56cc533d19c14c1aa234bd7d6e3
```

可以看出，md5 会随着时间的偏移改变。在计算文件差异的时候，经常不需要关系此种信息，我们可以使用 `-X` 参数去除extra属性。

### zip文件的时间计算

研究了下zip文件的格式，在 **Local file header** 中有一个对应的文件修改日期和修改时间字段，分别为2个字节，如下(小端模式下，读取时需要倒序):

| Offset  | 字符        | 备注                     |
| ------- | ----------- | ------------------------ |
| 0       | 50 4b 03 04 | 头部魔数                 |
| 4       | 0a 00       | 版本 (10)                |
| 6       | 00 00       | 标记, 加密与否           |
| 8       | 00 00       | 压缩算法                 |
| 10      | 89 aa       | 最近修改时间 (这个) |
| 12      | 71 4e       | 最近修改日期 (这个) |
| 14      | 2d 3b 08 af | crc-32                   |
| 18      | 0c 00 00 00 | 压缩大小，12B (12)       |
| 22      | 0c 00 00 00 | 未压缩大小，12B          |
| 26      | 09 00       | 文件名字长度 (9)         |
| 28      | 1c 00       | 扩展区域长度 (28)        |
| 30      |             | 文件内容                 |


#### 最近修改时间

aa89 = 10101 010100 01001 =  21:20:09

#### 最近修改日期

4e71 = 0100111 0011 10001 = 39-03-17(年+1980) = 2019-03-17


### 参考

1. [http://adoyle.me/blog/why-zip-file-checksum-changed.html](http://adoyle.me/blog/why-zip-file-checksum-changed.html)
2. [https://opensource.apple.com/source/zip/zip-6/unzip/unzip/proginfo/extra.fld](https://opensource.apple.com/source/zip/zip-6/unzip/unzip/proginfo/extra.fld)


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
