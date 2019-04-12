---
layout: post
title: 'Ubuntu Vim中文显示'
date: '2015-07-25'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---

英文版的Ubuntu系统自带的编码是en_US.UTF-8，并不包含中文编码集，可以在以下文件中查看:

	/var/lib/locales/supported.d/local
	
默认情况下，使用vim打开含有中文的文本后，看到的将是乱码。

怎么显示中文呢?  

1. **生成中文编码集**
2. **添加vim编码**


### 生成中文编码集

将中文编码集加入系统:

	sudo /var/lib/locales/supported.d/local
	
将下面加入该local文件末尾

	zh_CN.UTF-8 UTF-8
	zh_CN.GBK GBK


> zh_CN.GBK/GBK：生成名为zh_CN.GBK的locale，采用GBK字符集。
>
> zh_CN.UTF-8/UTF-8：生成名为zh_CN.UTF-8的locale，采用UTF-8字符集。
	
加入后，执行命令，重新生成编码集:
	
	sudo dpkg-reconfigure locales

### 添加vim编码

给vim设置文件编码:

	vim ~/.vimrc
	或
	sudo vim /etc/vim/vimrc
	
加入以下部分：

	set fileencodings=utf-8,gbk
	set termencoding=utf-8
	set encoding=prc 

再次使用vim打开含有中文的文本，正常显示了。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
