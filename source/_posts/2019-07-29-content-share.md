---
layout: post
comments: true
title: '内容共享'
date: '2019-07-29'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

### 背景

工作时有两台主力电脑，一台Mac，一台Ubuntu，之前经常基本上是Mac共享内容给Ubuntu，也有了[剪切板同步](/2019/04/17/clipboard-sync)这篇文章。随着Ubuntu上做的事情越来越多，也需要反向共享，结合日常工作中也需要和很多业务方同学来进行文本、图片的共享，于是决定做一个简单内容共享的Web应用。

### 目标

- 多设备间可以访问，共享文本和图片。
- 支持房间，可以针对特定的共享有单独的区域。
- 支持设置访问密码。(目前暂不支持)
- PC端直接粘贴即可，提升效率。
- 自动清理信息，清理24小时内没有任何访问的房间。

### Demo

[share.codeboy.org](http://share.codeboy.org)

### 部署

1. 下载[clipboard-0.0.1.jar](http://cdn.codeboy.org/clipboard-0.0.1.jar)
2. 执行以下命令即可
```
java -jar clipboard-0.0.1.jar
```

> 默认80端口，如果需要修改，可以 `application.properties` 中端口号即可。

### 二次开发

项目基于 `SpringBoot` + `thymeleaf` 开发，可以在此基础上进一步改造。
项目地址： [https://github.com/androiddevelop/ContentShare](https://github.com/androiddevelop/ContentShare)




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
