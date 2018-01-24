---
layout: post
title: 'Java Integer.valueOf'
date: '2018-01-07'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

Java泛型是JDK 5中引入的一个新特性，允许在定义类和接口的时候使用类型参数。


## 泛型类

泛型类是我们最经常使用的泛型形式了，如下:

	/**
	 * 工具类
	 * Created by yuedong.li on 12/8/15.
	 */
	public class ToolsUtil<T> {
	    /**
	     * if-else替代
	     * @param condition 条件
	     * @param t1 对象1
	     * @param t2 对象2
	     * @return 结果
	     */
	    public T ifThenElse(boolean condition, T t1, T t2) {
	        if (condition) {
	            return t1;
	        }
	        return t2;
	    }
	}


> 一个工具类，当前用来代替if-else

使用方法也很简单

	public class Main {
	    public static void main(String[] args) {
	        double res = new ToolsUtil<Double>().ifThenElse(1 > 2, 1.0, 2.0);
	        System.out.println(res);
	    }
	}


## 泛型方法

随着需求越来越多，工具类 `ToolsUtil` 可能需要增加很多的工具类，但是并非其他的方法的参数返回值等都是 `T` ,我们需要进行粒度调整，这时候就是泛型方法表现的时候了。

	/**
	 * 工具类
	 * Created by yuedong.li on 12/8/15.
	 */
	public class ToolsUtil {
	    /**
	     * if-else替代
	     * @param condition 条件
	     * @param t1 对象1
	     * @param t2 对象2
	     * @param <T> 类型
	     * @return 结果
	     */
	    public <T> T ifThenElse(boolean condition, T t1, T t2) {
	        if (condition) {
	            return t1;
	        }
	        return t2;
	    }

	    /**
	     * 检查Email
	     *
	     * @param email
	     *         email
	     * @return 是否是合法邮件
	     */
	    public static boolean checkEmail(String email) {
	        boolean result = false;
	        //some code about checking email string
	        return result;
	    }
	}

上面的代码我们使用泛型方法将 `ifThenElse` 函数的独立出来了，不再必须在创建 `ToolsUtil` 类时必须指定了。

使用方法依旧相对容易:

	public class Main {
	    public static void main(String[] args) {
	        double res = new ToolsUtil().ifThenElse(1 > 2, 1.0, 2.0);
	        System.out.println(res);
	        boolean checkRes = new ToolsUtil().checkEmail("app@codeboy.me");
	        System.out.println(checkRes);
	    }
	}

可以看出创建 `ToolsUtil` 的时候不需要再指定类型了，代码看起来清爽了很多。

我们经常将工具类的方法写成静态下，当然泛型方法也是可以的:

	/**
	 * 工具类
	 * Created by yuedong.li on 12/8/15.
	 */
	public class ToolsUtil {
	    /**
	     * 检查Email
	     *
	     * @param email
	     *         email
	     * @return 是否是合法邮件
	     */
	    public static boolean checkEmail(String email) {
	        boolean result = false;
	        //some code about checking email string
	        return result;
	    }


	    /**
	     * if-else替代
	     * @param condition 条件
	     * @param t1 对象1
	     * @param t2 对象2
	     * @param <T> 类型
	     * @return 结果
	     */
	    public static <T> T ifThenElse(boolean condition, T t1, T t2) {
	        if (condition) {
	            return t1;
	        }
	        return t2;
	    }
	}

使用更加的简洁，操作如下:

	public class Main {
	    public static void main(String[] args) {
	        double res = ToolsUtil.ifThenElse(1 > 2, 1.0, 2.0);
	        System.out.println(res);
	        boolean checkRes = ToolsUtil.checkEmail("app@codeboy.me");
	        System.out.println(checkRes);
	    }
	}

**需要注意的一点是 `<T>` 必须在` 修饰词 `(public private static final等)和`返回值`之间**

## 总结

泛型方法在什么时候使用呢？

#### ①类型约束只是在局部
	
泛型的作用于不是针对全局，而仅仅是针对局部的时候，如 `ToolsUtil` 类

#### ②静态方法需要处理泛型

如上面例子中的`ifThenElse`,普通的静态方法是不能使用泛型的。



> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
