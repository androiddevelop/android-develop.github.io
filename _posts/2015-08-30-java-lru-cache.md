---
layout: post
title: 'Java LruCache'
date: '2015-08-30'
header-img: "img/post-bg-java.jpg"
tags:
     - java
     - android
author: 'Codeboy'
---
为了更好的使用内存，操作系统中有一种Lru(Least Recently Used)策略,将最近最少使用的项移出容量有限的内存。不仅仅操作系统这样做，平时做一些android应用等也需要在有限的空间内保存一些状态。下面来看分析我们要怎么做这个基于Lru策略的缓存:

- **能够快速的读取与写入** ①
- **能够实现Lru策略** ②
- **能够适应多线程并发访问操作** ③
- **多个线程可以同时读取,但是写操作与读操作,写操作与写操作互斥** ④

## 快速的读取与写入

快速的读入与写入很容易是我们想起使用HashMap，而不是使用ArrayList等非结构，因为ArrayList在查找的时候需要遍历进行，不能够适应快读的读取，而HashMap使用hash值能够很快的读取对应的项，在写入方面ArrayList直接写入线性表的下一项，操作很快，HashMap需要对存入的key进行hash计算，之后检测是否有碰撞发生，整体上比ArrayList差一点。在数据量比较大的时候，ArrayList的读取速度和HashMap差距很大。

## 能够实现Lru策略

实现Lru策略需要记录元素的添加与访问顺序，需要不断的调整结构，链表将是不二直选，java中提供了LinkedHashMap可以方便实现Lru策略。


## 能够适应多线程并发访问操作

能够适应并发操作，则需要保证一些数据的同步，需要对相应的数据加锁操作。


## 读写锁

Java1.5中提供了读写锁(ReadWriteLock)，可能保证多个线程可以同时读取,但是写操作与读操作,写操作与写操作互斥。


## 实现

```
package me.codeboy.util;

import java.util.LinkedHashMap;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * 基于LRU策略的缓存
 * Created by yuedong on 8/26/15.
 */
public class LruCache<K, V> {
    private int MAX_LENGTH = 1 << 30;  //最大长度
    private LinkedHashMap<K, V> map;
    private ReadWriteLock lock = new ReentrantReadWriteLock(); //读写锁

    public LruCache(int initLength) {
        this(initLength, MAX_LENGTH);
    }

    public LruCache(int initLength, int maxLength) {
        MAX_LENGTH = maxLength;
        map = new LinkedHashMap<K, V>(initLength, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Entry<K, V> eldest) {
                return size() > MAX_LENGTH;
            }
        };
    }

    /**
     * 添加项
     *
     * @param item  项
     * @param state 状态
     */
    public void put(K item, V state) {
        lock.writeLock().lock();
        map.put(item, state);
        lock.writeLock().unlock();
    }

    /**
     * 获取值,使用前请判断是否存在item
     *
     * @param item 项
     * @return value 值
     */
    public synchronized V get(String item) {
        lock.readLock().lock();
        V value = map.get(item);
        lock.readLock().unlock();
        return value;
    }

    /**
     * 是否存在
     *
     * @param item 项
     * @return 是否存在
     */
    public boolean containsKey(String item) {
        lock.readLock().lock();
        boolean isContainer = map.containsKey(item);
        lock.readLock().unlock();
        return isContainer;
    }

    /**
     * 删除item
     *
     * @param item 项
     */
    public void remove(String item) {
        lock.writeLock().lock();
        map.remove(item);
        lock.writeLock().unlock();
    }
}
```
> LinkedHashMap是HashMap的子类，不仅有HashMap的功能，同时能够记录元素的添加顺序，提供了按照添加顺序(默认,accessOrder=false)和访问顺序的方式进行链表链接.
> 
> 重写LinkedHashMap的removeEldestEntry方法可以实现在size超过指定大小时按照Lru或者插入顺序删除相应的元素

## 使用

- 为了保证数据的统一性，持有LruCache的对象需要使用单例模式。
- 估计数据量，初始化给出初始容量以及最大容量，减少Map的resize操作。



> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
