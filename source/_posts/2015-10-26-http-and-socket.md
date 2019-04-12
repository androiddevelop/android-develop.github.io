---
layout: post
title: 'Http与Socket'
date: '2015-10-26'
header-img: "img/post-bg-java.jpg"
tags:
     - network
     - java
author: 'Codeboy'
---

一直对 `Http` 与 `Socket` 比较的疑惑，之前认为 `Http` 与 `Socket` 是两个完全不相关的概念，其实不然，这里对这两个词进行一下对比。

![](/img/http-and-socket.png)

	　Socket则是对TCP/IP协议的封装和应用(程序员层面上)。
	　
	  TPC/IP协议是传输层协议，主要解决数据如何在网络中传输，

	　HTTP是应用层协议，主要解决如何包装数据。

Socket跟TCP/IP协议没有必然的联系，实际上Socket是对TCP/IP协议的封装(不仅仅只是对TCP的封装)，Socket本身并不是协议，而是一个调用接口。

Http请求可以通过Socket接口进行操作，Java中的HttpURLConnection底层也是使用Socket进行数据发送的([具体原因请点击查看](http://zhoujianghai.iteye.com/blog/1195988))。下面看一下怎么使用Socket发送Http请求。


	
	import java.io.BufferedReader;
	import java.io.IOException;
	import java.io.InputStreamReader;
	import java.io.PrintWriter;
	import java.net.InetAddress;
	import java.net.Socket;

	/**
	 * socket模拟http请求
	 * Created by yuedong on 7/22/15.
	 */
	public class Main {
	    public static void main(String[] args) throws IOException {

	        Socket s = new Socket(InetAddress.getByName("codeboy.me"), 80);
	        PrintWriter pw = new PrintWriter(s.getOutputStream());
	        pw.println("GET / HTTP/1.1");
	        pw.println("Host: codeboy.me");
	        pw.println();
	        pw.flush();
	        BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));
	        String t;
	        while ((t = br.readLine()) != null) {
	            System.out.println(t);
	        }
	        br.close();
	    }
	}

执行后正确输出结果。我们在发送Socket请求时加上对应的Http头部信息就可以正确获取信息了。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
