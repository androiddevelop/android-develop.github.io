---
layout: post
comments: true
title: 'HashSet.add覆盖问题'
date: '2019-07-04'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

### 背景

假定对象A、B的hash值相同，equals方法也想等，那么向 `HashSet` 中顺序添加A、B，最后集合中保留的是A或者B或者是A和B呢？

### 编码

看以下代码，分析下输出：

```java
package me.codeboy.test.hash;

import java.util.Objects;

/**
 * hash bean
 * Created by yuedong.li on 2019-07-01
 */
public class HashBean {
    String value;

    @Override
    public boolean equals(Object obj) {
        return true;
    }

    @Override
    public int hashCode() {
        return Objects.hash("test");
    }

    @Override
    public String toString() {
        return value;
    }
}
```


```java
package me.codeboy.test.hash;

import com.google.common.collect.Maps;

import java.util.HashSet;
import java.util.Map;

/**
 * set add问题
 * Created by yuedong.li on 2019-07-01
 */
public class SetAdd {
    public static void main(String[] args) {
        HashBean bean = new HashBean();
        bean.value = "first";
        HashBean bean2 = new HashBean();
        bean2.value = "second";

        HashSet<HashBean> set = new HashSet<>();
        set.add(bean);
        set.add(bean2);
        System.out.println(set.size());
        System.out.println(set.iterator().next().value);

        System.out.println();
        Map<HashBean, String> map2 = Maps.newHashMap();
        map2.put(bean, "first");
        map2.put(bean2, "second");
        System.out.println(map2.size());
        System.out.println(map2.values().iterator().next());
        System.out.println(map2.keySet().iterator().next());
    }
}
```

### 分析

这里先贴一下输出的结果:

```nohighlight
1
first

1
second
first
```

为什么会是这样的呢？我们先看一下Jdk1.8.0中 `HashSet.add` 方法的调用栈:

```java
## HashSet
public boolean add(E e) {
	return map.put(e, PRESENT)==null;  //这里直接使用的是hashMap，将值当作key记录
}

## HashMap 
/**
 * Associates the specified value with the specified key in this map.
 * If the map previously contained a mapping for the key, the old
 * value is replaced.
 *
 * @param key key with which the specified value is to be associated
 * @param value value to be associated with the specified key
 * @return the previous value associated with <tt>key</tt>, or
 *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
 *         (A <tt>null</tt> return can also indicate that the map
 *         previously associated <tt>null</tt> with <tt>key</tt>.)
 */
public V put(K key, V value) {
  return putVal(hash(key), key, value, false, true);
}

/**
 * Implements Map.put and related methods
 *
 * @param hash hash for key
 * @param key the key
 * @param value the value to put
 * @param onlyIfAbsent if true, don't change existing value
 * @param evict if false, the table is in creation mode.
 * @return previous value, or null if none
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict的);
    return null;
}
```

从代码中可以看出，`HashSet.add` 直接调用`HashMap.put` 方法，`HashSet`的内部实现也确实是`HashMap`,  `HashSet.add` 的值直接作为`HashMap`的key进行存储，从`HashMap.putVal` 方法中可以看出，`HashMap`的key并没有做替换，在 `onlyIfAbsent`是false或者原先值为null的情况下，新value会替换旧value。

### 小结

`HashSet`在add的时候，在两个对象相等的情况下，是不进行替换的。

`HashMap`在put的时候，在两个key相等的情况下，是不进行替换的，在两个value相同的情况下，是要根据 `putVal` 方法中的`onlyIfAbsent`字段进行决定的。 


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
