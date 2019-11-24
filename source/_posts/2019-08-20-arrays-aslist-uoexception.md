---
layout: post
comments: true
title: 'Arrays.asList之UnsupportedOperationException'
date: '2019-08-20'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

### 前言

Java中经常会数组转化为List的场景，Java中的`Arrays` 中提供了一个 `asList` 方法可以快捷的转化，我们来看下面一段代码：

```java
import java.util.Arrays;
import java.util.List;

public class Test {
    public static void main(String[] args) {
        String a = "a,a,a";
        List<String> list = Arrays.asList(a.split(","));
        list.add("b");
        System.out.println(list.size());
    }
}
```

这个会输出什么样的结果呢？

### 分析

运行后，程序抛出了异常，如下:

```
Exception in thread "main" java.lang.UnsupportedOperationException
	at java.util.AbstractList.add(AbstractList.java:148)
	at java.util.AbstractList.add(AbstractList.java:108)
	at me.codeboy.test.Test.main(Test.java:8)
```

为什么会出现这个呢，我们查看下 `Arrays.asList`  的代码:

```
public static <T> List<T> asList(T... a) {
	return new ArrayList<>(a);
}
```

其中的 `ArrayList` 并非我们常用的 `java.util.ArrayList`, 而是 `Arrays` 中的一个内部类，同时这个内部类并没有实现 `add` 、`remove` 等操作。

```java
private static class ArrayList<E> extends AbstractList<E>
    implements RandomAccess, java.io.Serializable
{
    private static final long serialVersionUID = -2764017481108945198L;
    private final E[] a;

    ArrayList(E[] array) {
        a = Objects.requireNonNull(array);
    }

    @Override
    public int size() {
        return a.length;
    }

    @Override
    public Object[] toArray() {
        return a.clone();
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T> T[] toArray(T[] a) {
        int size = size();
        if (a.length < size)
            return Arrays.copyOf(this.a, size,
                                 (Class<? extends T[]>) a.getClass());
        System.arraycopy(this.a, 0, a, 0, size);
        if (a.length > size)
            a[size] = null;
        return a;
    }

    @Override
    public E get(int index) {
        return a[index];
    }

    @Override
    public E set(int index, E element) {
        E oldValue = a[index];
        a[index] = element;
        return oldValue;
    }

    @Override
    public int indexOf(Object o) {
        E[] a = this.a;
        if (o == null) {
            for (int i = 0; i < a.length; i++)
                if (a[i] == null)
                    return i;
        } else {
            for (int i = 0; i < a.length; i++)
                if (o.equals(a[i]))
                    return i;
        }
        return -1;
    }

    @Override
    public boolean contains(Object o) {
        return indexOf(o) != -1;
    }

    @Override
    public Spliterator<E> spliterator() {
        return Spliterators.spliterator(a, Spliterator.ORDERED);
    }

    @Override
    public void forEach(Consumer<? super E> action) {
        Objects.requireNonNull(action);
        for (E e : a) {
            action.accept(e);
        }
    }

    @Override
    public void replaceAll(UnaryOperator<E> operator) {
        Objects.requireNonNull(operator);
        E[] a = this.a;
        for (int i = 0; i < a.length; i++) {
            a[i] = operator.apply(a[i]);
        }
    }

    @Override
    public void sort(Comparator<? super E> c) {
        Arrays.sort(a, c);
    }
}
```

`AbstractList` 的实现中，默认 `add`、 `remove`方法的实现是抛出异常，这下就明白了。

```java
public void add(int index, E element) {
    throw new UnsupportedOperationException();
}
public void remove(int index) {
    throw new UnsupportedOperationException();
}
```



### 小结

使用 `Arrays.asList` 时，如果需要对结果进行修改，需要构建 `java.util.ArrayList` 之后在进行操作，不能在 `Arrays.asList` 的产物上直接进行操作。



> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
