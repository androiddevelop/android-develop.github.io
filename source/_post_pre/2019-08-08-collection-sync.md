---
layout: post
comments: true
title: 'Java中的同步操作'
date: '2019-08-08'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

### 背景

经常

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
```nohighlight
java -jar clipboard-0.0.1.jar
```

> 默认80端口，如果需要修改，可以 `application.properties` 中端口号即可。

### 二次开发

项目基于 `SpringBoot` + `thymeleaf` 开发，可以在此基础上进一步改造。
项目地址： [https://github.com/androiddevelop/ContentShare](https://github.com/androiddevelop/ContentShare)



https://zhuanlan.zhihu.com/p/73899015




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
