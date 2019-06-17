---
layout: post
comments: true
title: 'Javascript的undefined和null'
date: '2019-06-17'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---

Javascript中的 `undefined` 和 `null` 非常的常见，它们有什么不同呢？首先看几个简单的示例：

```nohighlight
var a = undefined;
var b = null;
console.log(a == b);
console.log(a === b);
console.log(typeof(a) == typeof(b));
console.log(a + 1);
console.log(b + 1);
```

上面的5个console日志会输出什么？

### 解析

`undefined` 在javascript中表示一个没有设置值的变量， `null` 表示一个空对象引用。从表示含义上可以很清楚的区分两者， 不过两者在部分使用上有一些差异，如下表：

| 特征     | undefined | null   |
| -------- | --------- | ------ |
| 含义     | 无        | 空对象 |
| 表示数据  | NaN       | 0      |
| 类型     | undefined | object |

以上几个示例:

```nohighlight
var a = undefined;
var b = null;
console.log(a == b);   // true
console.log(a === b);   // false
console.log(typeof(a) == typeof(b));   // false
console.log(a + 1);    // NaN
console.log(b + 1);  // 1
```

针对这两个的经典场景，在阮一峰老师的文章[undefined与null的区别](http://www.ruanyifeng.com/blog/2014/03/undefined-vs-null.html)中给出了说明，这里引用一下。

**null典型用法是**：

```nohighlight
（1） 作为函数的参数，表示该函数的参数不是对象。
（2） 作为对象原型链的终点。
```

**undefined典型用法是**：

```nohighlight
（1）变量被声明了，但没有赋值时，就等于undefined。
（2) 调用函数时，应该提供的参数没有提供，该参数等于undefined。
（3）对象没有赋值的属性，该属性的值为undefined。
（4）函数没有返回值时，默认返回undefined。
```

### 小结

`undefined` 和 `null` 在javascript中的含义相近，存在差异， `undefined` 的场景更多一些。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。