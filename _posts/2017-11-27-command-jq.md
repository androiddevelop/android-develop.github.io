---
layout: post
title: 'Shell下解析Json之jq'
date: '2017-11-27'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---


Json是一种轻量级的数据交换格式，简洁和清晰的层次结构使得Json成为理想的数据交换语言，易于人阅读和编写，同时也易于机器解析和生成，并有效地提升网络传输效率。

软件开发中经常会将对象序列化为Json，或者将对应的Json串反序列化为对象，在Android开发、服务端开发中都有很多库，如fastjson、gson等, 今天来看一下shell的json解析工具jq。

### 一、安装
jq的官网地址[https://github.com/stedolan/jq](https://github.com/stedolan/jq)

#### 1. mac
	brew install jq

#### 2. linux
	apt-get install jq
	
> ubuntu以及衍生版本可以直接仓库安装， 其他的发行版也可以尝试仓库或者源码编译

### 二、基本用法



> 更加详细的文档可以参见 [https://stedolan.github.io/jq/manual](https://stedolan.github.io/jq/manual/)



### 三、场景使用
获取[小胖轩](https://www.codeboy.me)博客中的文章列表，由于之前小胖轩网站中加入了博客搜索功能，有一个对应的文章索引[https://www.codeboy.me/search/cb-search.json](https://www.codeboy.me/search/cb-search.json)，我们需要做的操作如下:

	1. 下载cb-search.json文件
	2. 解析json文件，遍历文章列表
	3. 输出文章列表d

然后使用jqc


### 四、小结
shell下写脚本非常的方便快捷，有了jq，可以更快的完成很多

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
