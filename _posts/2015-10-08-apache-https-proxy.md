---
layout: post
title: 'Apache下Https反向代理Http'
date: '2015-10-08'
header-img: "img/post-bg-unix.jpg"
tags:
     - server
author: 'Codeboy'
---


尽管很多加密算法都做的很好了，但是在网页登录或注册时还是存在一定的号码被盗风险。怎么才能进一步加强信息的安全的，https是一个很好的选择。

> HTTPS（Hyper Text Transfer Protocol over Secure Socket Layer），是以安全为目标的HTTP通道，简单讲是HTTP的安全版。即HTTP下加入SSL层，HTTPS的安全基础是SSL，因此加密的详细内容就需要SSL。 它是一个URI scheme（抽象标识符体系），句法类同http:体系。用于安全的HTTP数据传输。https:URL表明它使用了HTTP，但HTTPS存在不同于HTTP的默认端口及一个加密/身份验证层（在HTTP与TCP之间）。这个系统的最初研发由网景公司(Netscape)进行，并内置于其浏览器Netscape Navigator中，提供了身份验证与加密通讯方法。现在它被广泛用于万维网上安全敏感的通讯，例如交易支付方面。
	
最近做了一个项目，项目部署在tomcat上，为了能够直接输入对应的域名进行访问，而不需要加入端口号，在apache服务器上做了http的反向代理，将域名反向代理到本机的tomcat服务器上，配置如下：

### Apache加载相应的模块

```
LoadModule proxy_module /usr/lib/apache2/modules/mod_proxy.so
LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
LoadModule proxy_connect_module /usr/lib/apache2/modules/mod_proxy_connect.so
LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so
```

> 1 在apache.conf中添加上述配置
>
> 2 可以使用此种方式加载模块，也可以在**mods-enabled**文件夹下进行软连接的建立


### 加入Http反向代理配置

```
<VirtualHost *:80>
    ServerAdmin service@domain.com
    ServerName sub.domain.com
    ProxyRequests Off 
    <Proxy *>
        Require all granted
    </Proxy>
    ProxyPass / http://127.0.0.1:8080/xxx/
    ProxyPassReverse / http://127.0.0.1:8080/xxx/
    ProxyPassReverseCookiePath /xxx /
</VirtualHost>
```


> 1 上述配置添加在**site-available**下的**000-default.conf**(一般是这个名字,路径 /etc/apache2/sites-available/)
>
>  2 此配置是将sub.domain.com反向代理到tomcat上的xxx项目下	

### 使用https反向代理xxx项目使其更加的安全
	
```
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
    ServerAdmin service@domain.com
    ServerName sub.domain.com
    ProxyRequests Off
    <Proxy *>
        Require all granted
    </Proxy>

    #反向代理配置
    ProxyPass / http://127.0.0.1:8080/xxxx/
    ProxyPassReverse / http://127.0.0.1:8080/xxxx/
    ProxyPassReverseCookiePath /xxxx /
    SSLEngine on
    
	#证书配置
    SSLCertificateFile    /usr/local/apache2/ssl/2_domain.com.crt
    SSLCertificateKeyFile /usr/local/apache2/ssl/3_domain.com.key

    SSLCertificateChainFile /usr/local/apache2/ssl/1_root_bundle.crt

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0
    # MSIE 7 and newer should be able to use keepalive
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

</VirtualHost>
```
	
> 1 上述配置添加在**site-available**下的**000-default-ssl.conf**(一般是这个名字，路径/etc/apache2/sites-available/)
>
>  2 此配置是将sub.domain.com反向代理到tomcat上的xxx项目下
	
	
	
### 强制将Http请求使用Https代替

**1.将所有的http请求全部转化为https请求**

```	
<VirtualHost *:80>
    ServerAdmin service@domain.com
    ServerName sub.domain.com
    ProxyRequests Off 
    
    #强制转化规则
    RewriteEngine on
    RewriteCond %{SERVER_PORT} !^443$
    RewriteRule ^(.*)?$ https://%{SERVER_NAME}$1 [L,R]
    
    	<Proxy *>
       	Require all granted
    	</Proxy>
    ProxyPass / http://127.0.0.1:8080/xxx/
    ProxyPassReverse / http://127.0.0.1:8080/xxx/
    ProxyPassReverseCookiePath /xxx /
</VirtualHost>
```


**2.仅仅将某个域名由http转化为https请求(多个子域名指向一台机器)**

```	
<VirtualHost *:80>
    ServerAdmin service@domain.com
    ServerName sub.domain.com
    Redirect / https://sub.domain.com
<VirtualHost>
```	

### 去除部分地址的Rewrite规则

我们将http都强制转化成https后会遇到一些问题，例如原本的部分页面使用iframe嵌套了一些http的页面，我们知道https页面嵌套http页面在chrome下将直接block，此时要么将这些http的页面转化为https的，要么将这些特殊的页面进行复原操作，不做https的转换，同时也要把是https开头的这些页面转化为http的。假设我们不需要对checkUpdate该地址进行操作，则在http的VirtualHost配置一下信息：
	
```
RewriteEngine on
RewriteCond %{SERVER_PORT} !^443$
RewriteCond %{REQUEST_URI} !checkUpdate$
RewriteRule ^(.*)?$ https://%{SERVER_NAME}$1 [L,R]
```

则在https的VirtualHost配置一下信息：

```
RewriteEngine on
RewriteCond %{REQUEST_URI} !checkUpdate$
RewriteRule ^(.*)?$ http://%{SERVER_NAME}$1 [L,R]
```

这样就可以将下述地址

```
http://xxxxx/checkUpdate?xxx=xxx
https://xxxxx/checkUpdate?xxx=xxx
```
	
转变为

```
http://xxxxx/checkUpdate?xxx=xxx
```
	
	
> 如有任何知识产权、版权问题或理论错误，还请指正。
> 
> 转载请注明原作者及以上信息。


