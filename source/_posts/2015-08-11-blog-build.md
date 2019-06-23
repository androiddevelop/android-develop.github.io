---
layout: post
comments: true
title: 'Codeboy Blog的搭建'
date: '2015-08-11'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---


本文介绍了[codeboy.me](http://codeboy.me)网站的搭建过程。

网站使用了jeykll进行构建，在CleanBlog等模板的基础上进行改造。jekyll是一个简单的免费的Blog生成工具，类似WordPress。但是和WordPress又有很大的不同，原因是jekyll只是一个生成静态网页的工具，不需要数据库支持。但是可以配合第三方服务,例如Disqus。最关键的是jekyll可以免费部署在Github上，而且可以绑定自己的域名。

下面介绍一下怎么搭建一个和codeboy.me外观相同的网站。

### 安装相应的:

1. 安装jeykll。

		gem install jekyll	

2. 将CodeboyBlog复制到服务器(部署到github.io的方式可以google一下，很多的文章)。
 	
		git clone https://github.com/androiddevelop/CodeboyBlog.git

3. 进行CodeboyBlog目录，运行命令生成网站即可。
    
		jekyll serve --watch &


为了能够更好的生成网站，我们可以写一个脚本:

    #!/bin/bash
    
    ps aux |grep jekyll |awk '{print $2}' | xargs kill -9
    cd /path/to/blog
    jekyll serve --watch &
    
    
> 命令解释：
> 
> ① ps开头的命令是关闭所有jekyll的进程
>
> ② cd到网站的根目录
>
> ③ 启动jekyll服务

### 需要配置的内容:
1. 修改_config.xml中的配置信息。
2. 修改_includes/footer.html中分享的信息。
3. 修改_layouts/page.html与_layouts/post.html中页面统计信息。
4. 修改_layouts/post.html中文章评论信息(更换为自己多说评论插件id)。
5. 修改about/index.html中个人信息。

### 更新内容:

1. 在Clean Blog的基础上修改，调整若干问题。
2. 加入文章搜索功能，pc上可以双击ctrl触发。
3. 优化界面，更好的适配手机。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
