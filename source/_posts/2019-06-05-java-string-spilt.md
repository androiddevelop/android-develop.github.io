---
"=12=".split("=")  //示例7layout: post
comments: true
title: 'Java String split'
date: '2019-06-05'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

Java中分割字符串经常会使用到 `String.split` ，本文中针对单字符分割的场景进行简单讨论，首先看几个例子:

```nohighlight
"".split("=")      //示例1
"=".split("=")     //示例2
"==".split("=")    //示例3
"=".split("=", 1)  //示例4
"=".split("=", 2)  //示例5
"=".split("=", 4)  //示例6
"=12=".split("=")  //示例7
"".split("=", 1)   //示例8
```

以上几个示例分割后的数组长度是多少呢？在本文小结中有结果，可以对比下是否和想象中是否一致，有出入的话可以一起来看下源码。

### 源码解析

基于jdk8来分析下 `String.split` 方法，`String.split`  有2个方法，分别如下：

```java
public String[] split(String regex)   //方法1
public String[] split(String regex, int limit) // 方法2
```

其中方法1直接调用方法2，传入`limit=0`

```java
public String[] split(String regex) {
        return split(regex, 0);
}
```

下面具体看一下方法2的实现

```java
public String[] split(String regex, int limit) {
  // 针对单字符分割，使用fastpath，没有使用正则java.util.regex.Pattern.split方法
  /* fastpath if the regex is a
    (1)one-char String and this character is not one of the
            RegEx's meta characters ".$|()[{^?*+\\", or
    (2)two-char String and the first char is the backslash and
            the second is not the ascii digit or ascii letter.
  */
  char ch = 0;
  if (((regex.value.length == 1 &&
        ".$|()[{^?*+\\".indexOf(ch = regex.charAt(0)) == -1) ||
       (regex.length() == 2 &&
        regex.charAt(0) == '\\' &&
        (((ch = regex.charAt(1))-'0')|('9'-ch)) < 0 &&
        ((ch-'a')|('z'-ch)) < 0 &&
        ((ch-'A')|('Z'-ch)) < 0)) &&
      (ch < Character.MIN_HIGH_SURROGATE ||
       ch > Character.MAX_LOW_SURROGATE))
  {
    int off = 0;
    int next = 0;
    // limit为0表示没有显示最大分割个数
    boolean limited = limit > 0;
    ArrayList<String> list = new ArrayList<>();
    while ((next = indexOf(ch, off)) != -1) {
      // 长度限制为1时，该条件不满足，直接进入else中，也即示例4、8的操作
      if (!limited || list.size() < limit - 1) {
        list.add(substring(off, next));
        off = next + 1;
      } else {    // last one
        //assert (list.size() == limit - 1);
        list.add(substring(off, value.length));
        off = value.length;
        break;
      }
    }
    // 示例1会进入的逻辑，因为示例1在上面的while中会直接跳出，off时默认值0
    // If no match was found, return this
    if (off == 0)
      return new String[]{this};

    //将最后一个添加进来
    // Add remaining segment
    if (!limited || list.size() < limit)
      list.add(substring(off, value.length));

    // 针对limit=0的场景，会循环去除最后一个空字符串，示例2、3会触发该条件
    // 为什么会针对limit=0的这种场景去除空字符串？感觉不能理解。
    // Construct result
    int resultSize = list.size();
    if (limit == 0) {
      while (resultSize > 0 && list.get(resultSize - 1).length() == 0) {
        resultSize--;
      }
    }
    String[] result = new String[resultSize];
    return list.subList(0, resultSize).toArray(result);
  }
  //多字符串分割本文不讨论
  return Pattern.compile(regex).split(this, limit);
}
```



### 小结

根据上面的例子, 我们可以看出，在不限定长度的情况下，split分割会去除数据末尾的所有空串。以上几种场景的结果如下:

| 类型                       | 结果       | 长度 |
| -------------------------- | ---------- | ---- |
| "".split("=")  //示例1     | [""]       | 1    |
| "=".split("=")  //示例2    | []         | 0    |
| "==".split("=")  //示例3   | []         | 0    |
| "=".split("=", 1)  //示例4 | ["="]      | 1    |
| "=".split("=", 2)  //示例5 | ["", ""]   | 2    |
| "=".split("=", 4)  //示例6 | ["", ""]   | 2    |
| "=12=".split("=")  //示例7 | ["", "12"] | 2    |
| "".split("=", 1)  //示例8  | [""]       | 1    |


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
