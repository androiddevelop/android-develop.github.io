---
layout: post
comments: true
title: '剪切板同步'
date: '2019-04-17'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---

工作中有两台主机，系统上一台macOS，一台Ubuntu，macOS作为主力机，经常需要将复制文本同步，之前的方案是登陆两个不同的微信进行分享，不过每次都需要打开，比较麻烦。

有没有什么办法能够解决 macOS 到 Ubuntu 的单向文本复制呢？单向解决了，双向基本也没有问题，鉴于作者没有双向需求，故本文只介绍 macOS 到 Ubuntu 的单项文本同步方案,。目前可行的方案有：

| 方案           | 优缺点                                  |
| -------------- | --------------------------------------- |
| IM、飞鸽传书   | 支持双向、操作流程略长                  |
| 剪切板同步软件 | 支持双向，多平台支持不够，很多没有Linux |
| SSH | 支持双向，多平台支持，配置稍微复杂，使用方便 |

本次采用外能的 ssh 进行剪切板同步，考虑到不希望把 macOS 上的剪切板全部同步，只需要同步需要的即可，结合 macOS 上另外一个神器 `alfred` 进行。

### 一、同步方案
macOS上操作剪切板非常的简单，`pbcopy` 和 `pbpaste` 分别对应复制和剪切，操作示例如下:

```nohighlight
➜  ~ echo "Hello Codeboy" | pbcopy 
➜  ~ pbpaste
Hello Codeboy
```

Linux上需要安装 `xclip` 来完成，操作示例如下:
```nohighlight
➜  ~ echo "Hello Codeboy" |  xclip -in -selection clipboard
➜  ~ xclip -o                                              
Hello Codeboy
```

由于 `xclip` 牵扯图形操作，不能直接使用ssh在远程主机上执行命令完成，我们使用文件进行内容传输即可，接收方定时检查文件是否有更新，有更新的话使用 `xclip` 同步到剪切板。
同时Ubuntu上需要配置 macOS 中 ssh 公钥，可以免密登陆，具体操作可以查询。

### 二、发送方(macOS)

我们使用 `alfred`中的workflow自定义快捷键执行脚本，操作如下：

- 新建空白workflow
- 添加Triggers --> HotKey, 定义喜欢的按键，作者选择(alt+F)，和复制键距离比较近。
- 新建Action --> Run Script, 输入复制脚本即可。

```bash
# 将剪切板内容写入文件
pbpaste > /tmp/clip_content
# 发送到目标主机
scp -q /tmp/clip_content user@host:/tmp/
```

这样需要复制的时候，`ctrl-C` 后再次按下 `alt-F` 即可发送。

### 三、接收方(Ubuntu)

接收方监听 `/tmp/clip_content` 文件内容变化即可，脚本如下:

```bash
#!/bin/bash
last_content=""
while true
do
 content=`cat /tmp/clip_content`
 if [ "$content" != "$last_content" ]
    then
      echo $content;
      xclip -in -selection clipboard < /tmp/clip_content
      last_content="$content"
 fi
 sleep 1
done
```

每秒钟检测该文件内容是否改变，改变的话复制到剪切板中，实时性还是很高的。打开终端，执行起来即可。

### 四、使用

macOS上遇到需要复制的文本，`ctrl-C --> alt-F` 后, 切换到Ubuntu，直接粘贴即可。有更快捷的方式欢迎留言。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
