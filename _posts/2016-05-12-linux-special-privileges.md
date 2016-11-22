---
layout: post
title: 'Linux特殊权限'
date: '2016-05-12'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---

Linux下常用的权限的有读、写和执行，也即常说的rwx，但是除了rwx权限外，Linux系统还有着一些特殊权限，他们是setUID、setGID和setBIT，同时还有一个chattr命令来修改文件的隐藏属性，具体介绍如下:

<p/>

## setUID

<hr/>

#### 1.功能

文件执行中将以属主(owner)身份运行

#### 2.使用前提

操作文件必须具有可执行权限

#### 3.命令操作

```
chmod 4xxx exec_file
chmod u+s exec_file
```

#### 4.检查文件

```
find / -perm -4000
```


<p/>
## setGID
<hr/>

#### 1.功能

- 操作对象是文件时，文件执行中将以组(group)身份运行
- 操作对象是目录时，在此目录中创建的文件或目录将继承上级目录的group组，即与父目录组是相同的

#### 2.使用前提

 - 操作的文件必须具有可执行权限
 - 操作的目录时需要具有相应的权限

#### 3.命令操作

```
chmod 2xxx exec_file/dir
chmod g+s exec_file/dir
```

#### 4.检查文件

```
find / -perm -2000
```

<p/>

## setBIT
<hr/>

#### 1.功能

如果目录被设置了setBIT，那么该目录下的文件，除文件创建者和root可以进行更改和删除操作外，其他用户不能进行更改删除操作

#### 2.使用前提

 - 操作对象为目录
 - 用户需要对该目录具有写(w)和执行(x)权限

#### 3.命令操作

```
chmod 1xxx dir
chmod o+t dir
```

#### 4.检查文件

```
find / -perm -1000
```

<p/>

## chattr
<hr/>

#### 1.功能

修改文件的隐藏属性，有很多的操作，常见的有a和i操作，a是让文件或目录仅供附加用途，i是不得任意更动文件或目录。

#### 2.命令操作

```
chattr +a file/dir
chattr +i file/dir
```

#### 3.查看

```
lsattr file/dir
```


<p/>

## 小结

 特征 | setUID | setGID| setBIT |chattr
 ----| --- | ----- | ----- | ---
 操作对象 | 文件 | 文件/目录 | 目录 | 文件/目录
 使用场景 | 以属组身份运行(例如passwd) | 以组身份运行文件,目录权限继承 | 防止其他用户更改删除文件 | 限制文件(目录)修改方式，例如只能追加

Linux特殊权限的设置需要非常的谨慎，错误的设置可能造成信息的泄露等。例如将vim设置为setUID后，那么普通用户就可以以root身份修改任何文件了。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
