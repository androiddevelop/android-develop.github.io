---
layout: post
comments: true
title: '同域代理'
date: '2018-01-07'
header-img: "img/post-bg-unix.jpg"
tags:
     - linux
author: 'Codeboy'
---

### 前沿

`跨域请求` 对于每一个前端开发应该都不会陌生，由于一些安全策略的限制，默认情况下浏览器不允许在一个域下请求另外一个域下的资源，例如 `www.codeboy.me` 下请求 `test.codeboy.me` 下的资源，相同的域要求协议、域名、端口都必须相同。

当前解决的方案有以下几种:
```no_highlight
1. JSONP
2. 同域请求
3. CORS(跨域资源共享)
```

`JSONP` 和 `CORS` 均需要服务端进行适当适配和改造，这里不再讲述，感兴趣的小伙伴可以自行查询。这里我们对同域请求的实现进行说明。

`同域请求` ,顾名思义就是将相同域下的请求进行代理，其实是一种 `反向代理` , 用最近项目开发中的一个例子来进行叙述和配置。前端页面部署在 `project.example.com` 中，服务端代码也部署在该服务器上，但是端口是 `9999` , 正常情况下，`http://project.example.com/test.html` 页面中是访问不到 `http://project.example.com:9999/api/getData` 的数据的，此事我们可以加一层代理，将  `http://project.example.com/api/getData` 全部代理转发到  `http://project.example.com:9999/api/getData` 即可。

### 准备环境

鉴于长期使用 `Apache Server` ，本次基于 `Apache 2.4.18` 进行，后端所有的接口均有 `/api` 开头。

### 期待目标

- 正常访问 `http://project.example.com` 可以请求到所有的静态资源
- 所有的 `http://project.example.com/api/**` 的请求代理到 `http://project.example.com:9999/api/**` 

### 服务器配置

在原有配置 `VirtualHost` 目录中，增加对 `/api`  的反向代理，由于同域，可以直接转发到 `127.0.0.1` 上即可。

```
<VirtualHost *:80>
	ServerAdmin admin@example.com
  ServerName project.example.com
	DocumentRoot /var/www/example
 
	<Directory /var/www/example>
		Options FollowSymLinks
		AllowOverride None
    Require all granted
	</Directory>

  ProxyPass /api/ http://127.0.0.1:9999/api/
  ProxyPassReverse /api/ http://127.0.0.1:9999/api/
  ProxyPassReverseCookiePath / /api
	
	LogLevel warn

	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

```




### 总结
使用 `同域代理` 后，服务端和前端代码都不需要进行修改，完美的解决了问题。最后还要说明的一点是：跨域请求被拒绝是在浏览器(客户端)上进行的，并不是服务端。


### 参考文章
- [所有人都应该知道的跨域及CORS](https://zhuanlan.zhihu.com/p/53996160)

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
