---
layout: post
comments: true
title: 'Intellij IDEA依赖同步及乱码问题'
date: '2016-03-03'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

随着 `Intellig IDEA` 的流行，越来越多的Java程序员开始用上这个更加强大的编译器。 `Intellig IDEA` 不仅可以智能联想，还集成了很多的工具，例如 `gradle`.


几个月来，`Intellig IDEA` 依赖同步一直困扰这我，最开始使用`Intellig IDEA` 的时候并没有出现任何问题，即便有时候依赖不能同步，重新启动`Intellig IDEA` 或者在终端下执行``` gradle --refresh-dependencies ``` 来进行更新依赖。 但是随着`Intellig IDEA` 的更新以及gradle等的更新，后面新建的项目在同步上一直存在问题，下面将依赖同步的问题以及web开发中遇到的一个中文乱码问题提供解决方案。

### 依赖同步

网上搜索到很多的解决方案是在gradle的窗口中，点击刷新按钮，但是最后并不能解决问题。起初的 `build.gradle` 文件内容如下:

```
group 'me.codeboy'
version '1.0-SNAPSHOT'

apply plugin: 'java'
apply plugin: 'war'

repositories {
    mavenLocal()
    jcenter()
}

dependencies {
    testCompile 'junit:junit:4.12'
    providedCompile 'javax.servlet:javax.servlet-api:3.1.0'
    compile 'org.apache.struts:struts2-core:2.3.20'
    compile 'me.codeboy.common:base:1.2.0'
    }

```

按照上面的配置，一直依赖不能整理好，后面发现是需要添加 ``` apply plugin: 'idea'  ``` ，添加后如下:

```
group 'me.codeboy'
version '1.0-SNAPSHOT'

apply plugin: 'idea'
apply plugin: 'java'
apply plugin: 'war'

repositories {
    mavenLocal()
    jcenter()
}

dependencies {
    testCompile 'junit:junit:4.12'
    providedCompile 'javax.servlet:javax.servlet-api:3.1.0'
    compile 'org.apache.struts:struts2-core:2.3.20'
    compile 'me.codeboy.common:base:1.2.0'
    }
```

之后命令行下运行以下命令即可：

```
gradle idea
```

### 中文乱码

在Web开发中，输出的日志和直接打印的汉字显示为问号，也即乱码。这个解决的办法比较容易，操作步骤如下：

1. 右上角运行左上角的箭头点开 
2. Edit Configurations 
3. Tomcat Server 
4. VM options 
5. 添加 `-Dfile.encoding=UTF-8` 即可



> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
