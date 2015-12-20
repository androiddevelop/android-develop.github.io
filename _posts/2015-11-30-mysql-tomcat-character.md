---
layout: post
title: 'Mysql与Tomcat编码问题'
date: '2015-11-30 20:06:00'
header-img: 'img/post-bg-unix.jpg'
tags:
- server
author: 'Codeboy'
---

日常中不论移动开发还是web开发，与中文相关的编码总是很奇怪，经常出现乱码。下面针对常用的数据库mysql与服务器tomcat进行编码配置说明，统一 `UTF-8.`

### Mysql

数据库基本上是一个项目不可缺少的部分了，mysql作为最通用的数据库，用户量非常的大, 下面针对的mysql在ubuntu系统下的编码进行配置，其他系统基本相同。

- 修正mysql配置文件/etc/mysql/my.cnf
	
		[client]下添加：
		default-character-set=utf8
		
		[mysqld]下添加：
		character-set-server=utf8

- 查看编码

		mysql> show variables like '%character%' ;
		+--------------------------+----------------------------+
		| Variable_name            | Value                      |
		+--------------------------+----------------------------+
		| character_set_client     | utf8                       |
		| character_set_connection | utf8                       |
		| character_set_database   | utf8                       |
		| character_set_filesystem | binary                     |
		| character_set_results    | utf8                       |
		| character_set_server     | utf8                       |
		| character_set_system     | utf8                       |
		| character_sets_dir       | /usr/share/mysql/charsets/ |
		+--------------------------+----------------------------+
		8 rows in set (0.00 sec)

输出的编码集不能含有latin。


### Tomcat

tomcat的配置比较简单，只需要在其`server.xml`中对应8080配置的那句话内加入URIEncoding="UTF-8"即可，如下：

	  <Connector URIEncoding="UTF-8" 
	  				connectionTimeout="20000" 
	  				port="8080" 
	  				protocol="HTTP/1.1" 
	  				redirectPort="8443"/>
	  				
之后请求tomcat服务的url地址栏中将会全面支持UTF-8编码。

### 总结

开发中应尽量减少中文的使用与传输，避免造成不必要的困扰，我们可以使用Base64等一些编码规则对汉字进行转化。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
