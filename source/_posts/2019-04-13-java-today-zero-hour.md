---
layout: post
comments: true
title: '零点时间'
date: '2019-04-13'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---


在一些按天计算的场景中，需要获取当天凌晨零点的时间，有什么快捷高效的做法呢？下面针对Java中的几种计算方式进行比较：

#### 1. SimpleDateFormat

获取当前时间对应的年月日，反向计算即可。

```java
   private static long getTimeWay1() {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.CHINA);
            return sdf.parse(sdf.format(System.currentTimeMillis())).getTime();
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return -1;
    }
```

#### 2. Calendar

使用 `java.util.Calendar` 类，可以便捷去除时分秒以及毫秒的数值，

```java
    private static long getTimeWay2() {
        Calendar calendar = Calendar.getInstance(TimeZone.getDefault());
        //注意，这里不是Calendar.HOUR, 需要按照24小时的Calendar.HOUR_OF_DAY进行
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTimeInMillis();
    }
```

#### 3. 除法

借鉴 `SimpleDateFormat` 的方式，本次直接使用除法操作即可，需要注意一点的是时区问题，东八区相对于零时区增加了八个小时，处理中需要处理一下。

```java
    private static long getTimeWay3() {
        long ONE_DAY = 24 * 3600 * 1000;
        long now = System.currentTimeMillis();
        long offset = TimeZone.getDefault().getRawOffset();
        return (now + offset) / ONE_DAY * ONE_DAY - offset;
    }
```

### 小结

| 方式             | 性能 | 使用             |
| ---------------- | ---- | ---------------- |
| SimpleDateFormat | 一般 | 一般             |
| Calendar         | 高   | 方便             |
| 除法             | 最高 | 时区问题需要注意 |

对比下来, 推荐使用第二种


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
