---
layout: post
comments: true
title: '正则表达式之非获取匹配'
date: '2017-10-01'
header-img: "img/post-bg-trick.jpg"
tags:
     - trick
author: 'Codeboy'
---

正则表达式是平时开发中经常用到的技巧，大部分时候我们需要的是判断字符串有没有含有固定的模式串，但是某些场景下需要使用非获取匹配，下面根据一种常见的情景:

**匹配所有含有 `app://page.cb/myPage?id=xxxx`的地址，但是排除参数中携带`downgrade=true`的地址。**

具体用几个例子说明一下:

```
原始地址: app://page.cb/myPage
匹配结果: no， id不存在

原始地址: app://page.cb/myPage?id=123456
匹配结果: yes

原始地址: app://page.cb/myPage?param=123456
匹配结果: no, id不存在

原始地址: app://page.cb/myPage?id=123456&downgrade=true
匹配结果: no, downgrade为true

原始地址: app://page.cb/myPage?id=123456&downgrade=false
匹配结果: yes

原始地址: app://page.cb/myPage?downgrade=false&id=123456
匹配结果: yes

原始地址: app://page.cb/myPage?downgrade=true&id=123456
匹配结果: no, downgrade为true
```

 匹配所有不含`downgrade=true`的`app://page.cb/myPage?id=xxxx`地址，这里可以使用正则表达式的非获取匹配，下面介绍非获取匹配的两种:

#### (?!pattern)

非获取匹配，正向否定预查，在任何不匹配pattern的字符串开始处匹配查找字符串，该匹配不需要获取供以后使用。例如“Windows(?!95&#124;98&#124;NT&#124;2000)"能匹配“Windows3.1"中的“Windows"，但不能匹配“Windows2000"中的“Windows"。

#### (?<!pattern)

非获取匹配，反向否定预查，与正向否定预查类似，只是方向相反。例如“(?<!95&#124;98&#124;NT&#124;2000)Windows"能匹配“3.1Windows"中的“Windows"，但不能匹配“2000Windows"中的“Windows"。


根据非获取匹配的写法， 我们采用了正向否定查询，正则表达式如下：

```
app:\/\/page.cb\/myPage\?(((?!downgrade=true).)*id=\d+((?!downgrade=true).)*)
```

对其中的反向预查部分进行分割如下：

<span style="background-color:#B5EF79; font-weight: 700;">app:\/\/page.cb\/myPage</span><span style="background-color:#FDBE73; font-weight: 700;">\?</span>(<span style="background-color:#77C5FD; font-weight: 700;">((?!downgrade=true).)*</span><span style="background-color:#B5EF79">id=\d+</span><span style="background-color:#77C5FD; font-weight: 700;">((?!downgrade=true).)*</span>)

可以在[https://regex101.com](https://regex101.com/) 中尝试匹配。

分析以上正则表达式，即 `id=\d+` 的前后都不能含有 `downgrade=true` ，其中 `((?!downgrade=true).)*` 从里到外看，`(?!downgrade=true)` 代表不含该字符串，然后.用于匹配id参数前后的其他参数,此处的.不能防止在 `(?!downgrade=true)` 的前面，会造成如果第一个参数是 `downgrade=true` 时被遗漏掉。

如果需要url中参数部分，其中$1即为参数部分。

测试case集合：
```
app://page.cb/myPage
app://page.cb/myPage?id=123456
app://page.cb/myPage?param=123456
app://page.cb/myPage?id=123456&downgrade=true
app://page.cb/myPage?id=123456&downgrade=false
app://page.cb/myPage?downgrade=false&id=123456
app://page.cb/myPage?downgrade=true&id=123456
```

> 由于各种语言对正则表达式支持程度不同，例如非获取匹配中的反向否定预查在javascript中不支持，但是在php,python,java中是支持的，正向否定预查在javascript,php,python,java中都支持，所以使用前一定要注意，同事需要考虑正则表达式的性能问题。
