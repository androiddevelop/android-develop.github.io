---
layout: post
comments: true
title: 'Java代理'
date: '2019-05-27'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

代理是在开发中经常用到的一种模式，不暴露真实的对象，取而代之的提供代理对象，在代理对象中可以对实际操作的前后进行一些处理，也即流行的面向切面编程(AOP)，Spring中的拦截器使用的就是代理模式。

我们对一个需要两步完成的任务，使用普通模式、静态代理、动态代理和cglib分别实现下：

### 准备工作

定义接口 `ITask` 和实现类 `Task`

```java
package me.codeboy.test.proxy;

/**
 * 任务
 * Created by yuedong.li on 2019-05-27
 */
public interface ITask {
    /**
     * 步骤一
     */
    public void step1();

    /**
     * 步骤二
     */
    public void step2();
}

```



```
package me.codeboy.test.proxy;

/**
 * 任务
 * Created by yuedong.li on 2019-05-27
 */
public class Task implements ITask {
    @Override
    public void step1() {
        System.out.println("step1 print task!!");
    }

    @Override
    public void step2() {
        System.out.println("step2 print task!!");
    }
}

```

### 普通模式

该模式下，创建 `Task` 实例后，直接调用对应方法

```java
package me.codeboy.test.proxy;

/**
 * 普通模式
 * Created by yuedong.li on 2019-05-27
 */
public class CommonMain {
    public static void main(String[] args) {
        ITask task = new Task();
        task.step1();
        task.step2();
    }
}
```

**运行结果**:

```nohighlight
step1 print task!!
step2 print task!!
```

### 静态代理

由一个代理类来进行实际方法调用

```java
package me.codeboy.test.proxy;

/**
 * 任务静态代理
 * Created by yuedong.li on 2019-05-27
 */
public class TaskStaticProxy implements ITask {
    private Task task;

    public TaskStaticProxy(Task task) {
        this.task = task;
    }

    @Override
    public void step1() {
        System.out.println("-----> before step1");
        task.step1();
        System.out.println("-----> after step1");
    }

    @Override
    public void step2() {
        System.out.println("-----> before step2");
        task.step2();
        System.out.println("-----> after step2");
    }
}
```

```java
package me.codeboy.test.proxy;

/**
 * 静态代理
 * Created by yuedong.li on 2019-05-27
 */
public class StaticProxyMain {
    public static void main(String[] args) {
        ITask task = new TaskStaticProxy(new Task());
        task.step1();
        task.step2();
    }
}
```

**运行结果**:

```nohighlight
> -----> before step1
> step1 print task!!
> -----> after step1
> -----> before step2
> step2 print task!!
> -----> after step2
```


### 动态代理

由Proxy创建一个代理 `ITask` 接口的代理来进行实际方法调用

```java
package me.codeboy.test.proxy;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * 任务动态代理
 * Created by yuedong.li on 2019-05-27
 */
public class TaskDynamicProxy implements InvocationHandler {
    private Task task;

    public TaskDynamicProxy(Task task) {
        this.task = task;
    }

    /**
     * 创建动态代理
     */
    public ITask getProxy() {
        return (ITask) Proxy.newProxyInstance(task.getClass().getClassLoader(), task.getClass().getInterfaces(), this);
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("-----> before " + method.getName());
        Object ret = method.invoke(task, args); //执行真正的方法
        System.out.println("-----> after " + method.getName());
        return ret;
    }
}
```

```java
package me.codeboy.test.proxy;

/**
 * 动态代理
 * Created by yuedong.li on 2019-05-27
 */
public class DynamicProxyMain {
    public static void main(String[] args) {
        ITask task = new TaskDynamicProxy(new Task()).getProxy();
        task.step1();
        task.step2();
    }
}
```

**运行结果**:

```nohighlight
-----> before step1
step1 print task!!
-----> after step1
-----> before step2
step2 print task!!
-----> after step2
```


### cglib代理

创建一个代理 `Task` 类的代理类来进行实际方法调用

```java
package me.codeboy.test.proxy;

import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.Method;

/**
 * cglib代理
 * Created by yuedong.li on 2019-05-27
 */
public class TaskCglibProxy<T> implements MethodInterceptor {

    /**
     * 获取代理对象
     *
     * @param object 对象
     * @return proxy 对象
     */
    public T getProxy(T object) {
        Enhancer enhancer = new Enhancer(); //创建Enhancer来生成动态代理类
        enhancer.setSuperclass(object.getClass());
        enhancer.setCallback(this);  //设置回调，之后所有的方法调用将会执行intercept方法
        return (T) enhancer.create();
    }

    /**
     * 代理对象的执行会回调到此方法中
     */
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("-----> before " + method.getName());
        Object result = proxy.invokeSuper(obj, args); //调用业务类的方法
        System.out.println("-----> after " + method.getName());
        return result;
    } 
}
```

```java
package me.codeboy.test.proxy;

/**
 * cglib代理
 * Created by yuedong.li on 2019-05-27
 */
public class CglibProxyMain {
    public static void main(String[] args) {
        ITask task = new TaskCglibProxy<ITask>().getProxy(new Task());
        task.step1();
        task.step2();
    }
}
```

**运行结果**:

```nohighlight
-----> before step1
step1 print task!!
-----> after step1
-----> before step2
step2 print task!!
-----> after step2
```


### 小结

根据上面的例子，简单的总结一下几种代理模式的使用场景和特点：

| 类型      | 场景             | 特点                                           |
| --------- | ---------------- | ---------------------------------------------- |
| 静态代理  | 代理比较简单的类 | 代理多个方法后会比较繁琐，可能会有很多重复代码 |
| 动态代理  | 代理接口         | 只能代理接口，不能代理实现类                   |
| cglib代理 | 代理实现类       | 和动态代理互补                                 |




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
