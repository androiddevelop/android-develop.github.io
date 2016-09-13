---
layout: post
title: 'Java静态泛型方法'
date: '2016-09-12'
header-img: "img/post-bg-java.jpg"
tags:
     - java
     - android
author: 'Codeboy'
---

Java在JDK 5中引入了泛型，使用起来方便了很多，下面是一段很常见的泛型使用：

```
List<String> list = new ArrayList<String>();
```

## 泛型方法使用

不仅集合中可以使用，在定义类和方法的时候也是经常使用的，但是关于泛型的静态方法使用的场景还是不太多。下面从求两个数的最大数的实现上来看一下它们的简单使用：

### 普通泛型方法

```
package me.codeboy.test;

/**
 * generic test
 * Created by yuedong on 9/12/16.
 */
public class MathTest<T extends Comparable> {

    public static void main(String[] args) {
        MathTest<Integer> mathTest1 = new MathTest<Integer>();
        MathTest<Double> mathTest2 = new MathTest<Double>();
        System.out.println(mathTest1.max(1, 2));
        System.out.println(mathTest2.max(2.0, 3.0));
    }

    private T max(T t1, T t2) {
        return t1.compareTo(t2) > 0 ? t1 : t2;
    }
}
```

### 静态泛型方法

```
/**
 * generic test
 * Created by yuedong on 9/12/16.
 */
public class MathTest {

    public static void main(String[] args) {
        System.out.println(max(1, 2));
        System.out.println(max(2.0, 3.0));
    }

    private static <T extends Comparable> T max(T t1, T t2) {
        return t1.compareTo(t2) > 0 ? t1 : t2;
    }
}


```

## 静态泛型方法优缺点

优点很明显，代码简洁多了，或者可以说比普通的泛型泛型更为简洁，网上有一段关于Android中频繁使用 `findViewById` 方法的静态泛型方法实现，被称为见过最牛逼的Android代码，但是事物都有两面性，静态泛型方法也有相应的缺点，再看一段代码:

```
import java.util.ArrayList;
import java.util.List;

/**
 * test entry
 * Created by yuedong on 9/10/16.
 */
public class Test {

    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("test");

        //普通转换
        ArrayList<String> result1 = (ArrayList<String>) list;

        //静态泛型转换
        String result2 = convert(list);
    }

    private static <T> T convert(Object a) {
        return (T) a;
    }
}
```

上述代码是 **编译通过，运行异常**，为什么会出现这种现象呢？这是因为Java的泛型方法属于伪泛型，在编译的时候将进行类型擦除。普通的泛型方法在类构建时已经明确制定了对应的类型，而在静态泛型方法中，类型是无法直接推测的，缺少了明确的类型，最终造成类型转化异常。

```
Exception in thread "main" java.lang.ClassCastException: java.util.ArrayList cannot be cast to java.lang.String
```

## 原理探索

看到了上面的结果，不禁还是想了解下泛型方法在类型擦除后最终转换成了什么，反编译class文件如下:

```
Compiled from "Test.java"
public class Test {
  public Test();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: new           #2                  // class java/util/ArrayList
       3: dup
       4: invokespecial #3                  // Method java/util/ArrayList."<init>":()V
       7: astore_1
       8: aload_1
       9: ldc           #4                  // String test
      11: invokeinterface #5,  2            // InterfaceMethod java/util/List.add:(Ljava/lang/Object;)Z
      16: pop
      17: aload_1
      18: checkcast     #2                  // class java/util/ArrayList
      21: astore_2
      22: aload_1
      23: invokestatic  #6                  // Method convert:(Ljava/lang/Object;)Ljava/lang/Object;
      26: checkcast     #7                  // class java/lang/String
      29: astore_3
      30: return
}
```

可以看到convert函数最终转化后对应的字节码为 `Method convert:(Ljava/lang/Object;)Ljava/lang/Object;` 参数为Object类型，返回也为Object类型，而在接下来的 `checkcast` 操作中，由于 `List` 和 `String` 类型的不同，所以抛出了异常。

```
    private static <T extends List> T convert(Object a) {
        return (T) a;
    }
```
对于上述的代码反编译后对应 `Method convert:(Ljava/lang/Object;)Ljava/util/List;` 中，可以看到此时参数为Object类型，返回为List类型。


## 小结

尽管Java中的泛型是伪泛型，但是泛型可以使代码更加的简洁，只是在使用 `静态泛型方法` 时需要特别注意类型转化，尽可能的缩小泛型类型。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
