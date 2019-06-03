---
layout: post
comments: true
title: '浮点精度'
date: '2019-05-07'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

整数、浮点数是开发中经常使用的类型，在Java中，整数常用的有 `Integer` 和 `Long` ，浮点数有 `Float` 和 `Double` 。如果使用 `Float` 来存储 `Integer` 的值可行么？粗略看上去，肯定是没问题的，下面我们看个例子:

```
public class Test {
    public static void main(String[] args) {
        int a = 12345678;
        System.out.println(a);
        System.out.println((float) a);
        System.out.println(Float.valueOf(a + "").intValue());
    }
}
```

结果会输出什么呢？

```
12345678
1.2345678E7
12345678
```

完全正确，不要急，我们将变量a的值调大一些，修改为 123456789，再次执行，输出结果如下:

```
123456789
1.23456792E8
123456792
```

差了一些，有误差了，这个为什么呢？因为浮点数的表示是按照 `IEEE 754 `标准的，可以参考<https://www.zhihu.com/question/21711083> , 字节数和尾数部分见下表：

| 类型   | 字节数 | 尾数长度 | 精确范围     |
| ------ | ------ | -------- | ------------ |
| Float  | 4      | 23       | -2^24 ~ 2^24 |
| Double | 8      | 52       | -2^53 ~ 2^53 |

因为最高位是1的缘故，加上尾数长度，可以计算出能够精确表示的范围，可以看出 `Float` 最大精确数值为 `16777216` ,`Double` 最大精确数值为 `9007199254740992` ，上文中的 `12345678` 和 `123456789` 刚好在 `16777216` 的两侧， 所以出现了上文中的结果。

### 小结

当前时间戳的范围超过了 `Float` 的范围，在进行类型转化时已经要注意。 需要精度高的类型，可以选择 `BigDecimal` 来完成，如果明确确定对应的数值大小在精确表示范围内，也可以进行转换。




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。