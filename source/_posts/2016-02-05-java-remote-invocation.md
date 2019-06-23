---
layout: post
comments: true
title: 'Java调用远程方法'
date: '2016-02-05'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

有时候我们需要能够及时的更新程序的部分逻辑，在java中可以使用相关远程调用技术，将相关的逻辑代码放置在服务器上，在适当的时候进行修改替换即可。下面介绍两种常见的方法:  `RMI(Remote Method Invocation)` 与 `URLClassLoader`.

### RMI

`rmi` 即 `Remote Method Invocation` ，操作步骤如下：

#### 定义远程接口

	package me.codeboy.test.rmi;

	import java.rmi.Remote;
	import java.rmi.RemoteException;

	/**
	 * server remote interface
	 * Created by YD on 2/5/16.
	 */
	public interface IServer extends Remote {
	    String getData() throws RemoteException; //获取数据
	}

#### 服务器接口实现

	package me.codeboy.test.rmi.server;

	import me.codeboy.test.rmi.IServer;

	import java.rmi.RemoteException;
	import java.rmi.server.UnicastRemoteObject;

	/**
	 * server implement
	 * Created by YD on 2/5/16.
	 */
	public class ServerImpl extends UnicastRemoteObject implements IServer {

	    public ServerImpl() throws RemoteException {
	    }

	    @Override
	    public String getData() throws RemoteException {
	        return "Hello, I am code boy.";
	    }
	}

#### rmi服务端实现

	import java.rmi.Naming;
	import java.rmi.registry.LocateRegistry;

	/**
	 * rmi server
	 * Created by YD on 2/5/16.
	 */
	public class RmiServer {

	    public static void main(String[] argv) {
	        try {
	            //注册rmi服务
	            LocateRegistry.createRegistry(1099);

	            ServerImpl server = new ServerImpl();

	            //绑定实例到指定的名称上
	            Naming.rebind("test", server);

	            CBPrint.print("Test server is ready.");
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }
	}

#### rmi客户端实现

	package me.codeboy.test.rmi.client;

	import me.codeboy.common.base.log.CBPrint;
	import me.codeboy.test.rmi.IServer;

	import java.net.MalformedURLException;
	import java.rmi.Naming;
	import java.rmi.NotBoundException;
	import java.rmi.RemoteException;

	/**
	 * rmi client
	 * Created by YD on 2/5/16.
	 */
	public class RmiClient {
	    public static void main(String args[]) throws RemoteException, MalformedURLException, NotBoundException {
	        String url = "rmi://127.0.0.1/test";
	        IServer server = (IServer) Naming.lookup(url);
	        CBPrint.print(server.getData());
	    }
	}

#### 运行
- 运行rmi server
- 运行rmi client

> 其中 `CBPrint` 使用第三方库[http://github.com/androiddevelop/CommonBase](http://github.com/androiddevelop/CommonBase)


### URLClassLoader

`URLClassLoader` 可以在客户端上加载服务端的jar包，利用反射机制进行方法的调用即可，Java的三个类加载器组成的初始类加载器 `bootstrap classloader` `extension classloader` `system classloader`, 其中后两个classloader都是 `URLClassLoader` 的子类。操作步骤如下:

#### 服务端程序

	package me.codeboy.test;

	import me.codeboy.common.base.log.CBPrint;

	/**
	 * main function
	 * Created by YD on 2/2/16.
	 */
	public class Test {
	    public static void main(String[] args) {
	        new Test().test();
	    }

	    /**
	     * 测试
	     */
	    public void test() {
	        CBPrint.print("Hello, I am from codeboy.me.");
	    }
	}

将上面测试类编译后打包成jar包，放置在服务器上，供客户端调用。

#### 客户端调用

	package me.codeboy.test;

	import java.lang.reflect.Method;
	import java.net.URL;
	import java.net.URLClassLoader;

	/**
	 * test
	 * Created by YD on 2/4/16.
	 */
	public class Main {
	    public static void main(String[] args) {
	        String jarURL = "http://example.codeboy.me/rmi/Test.jar";
	        try {
	            URLClassLoader classLoader = new URLClassLoader(new URL[]{new URL(jarURL)});
	            Class cls = classLoader.loadClass("me.codeboy.test.Test");
	            Method method = cls.getDeclaredMethod("test");
	            method.invoke(cls.newInstance());
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }
	}

运行后输入以下结果：

	Hello, I am from codeboy.me.


其中[http://example.codeboy.me/rmi/Test.jar](http://example.codeboy.me/rmi/Test.jar)即为服务端的jar包，`me.codeboy.test.Test` 是对应的类， `test` 是Test类中的方法。 





> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
