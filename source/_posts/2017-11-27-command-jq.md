---
layout: post
comments: true
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

#### mac
	brew install jq

> mac下安装时可能会提示更新xcode，如提示请更新。

#### linux
	apt-get install jq
	
> ubuntu以及衍生版本可以直接仓库安装， 其他的发行版也可以尝试仓库或者源码编译

### 二、基本用法
解析json最常用的要数取值和获取数组长度操作了，给出一段常见的json，结合场景介绍下简单的使用：
```
{
  "data": [
    "张三",
    "李四"
  ],
  "code": "SUCCESS"
}
```

假定content代表上面的字符串。

jq获取字段时的格式为`.字段名`，例如获取code值时，操作如下:

```
echo $content | grep '.code'
```

获取data的长度的格式如下`'length'`,直接使用不加.的length即可，操作如下:

```
echo $content | jq '.data|length'
echo $content | jq '.data' | jq 'length'
```


> 更加详细的文档可以参见 [https://stedolan.github.io/jq/manual](https://stedolan.github.io/jq/manual/)


### 三、场景使用
获取[小胖轩](https://www.codeboy.me)博客中的文章列表，由于之前小胖轩网站中加入了博客搜索功能，有一个对应的文章索引[https://www.codeboy.me/search/cb-search.json](https://www.codeboy.me/search/cb-search.json)，我们需要做的操作如下:

	1. 下载cb-search.json文件
	2. 解析json文件，遍历文章列表
	3. 输出文章标题列表

然后使用jq进行解析即可:

```
#!/bin/bash
# 获取codeboy.me中所有文章的标题

json=`curl -s "https://www.codeboy.me/search/cb-search.json"`;

#获取文章列表
list=`echo $json | jq '.data'`;

#获取文章长度
length=`echo $json | jq'.data|length' `;

# 解析data字段后，开始遍历每一项，取出标题
for index in `seq 0 $length`
do
	echo $list | jq ".[$index].title";
done

```

### 四、小结
shell下写脚本非常的方便快捷，有了jq，可以完成更丰富的操作。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
