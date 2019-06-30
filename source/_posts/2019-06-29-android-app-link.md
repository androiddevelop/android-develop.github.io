---
layout: post
comments: true
title: 'Andorid AppLink配置'
date: '2019-06-29'
header-img: "img/post-bg-android.jpg"
tags:
     - android
author: 'Codeboy'
---

### 前言

客户端开发中，经常会遇到appA跳转appB的场景，之前Android中使用比较多的是 `DeepLink`，ios中对应的是 `Scheme`, 两者基本类似，在用户触发某个操作后，系统提示是否打开对应app，用户选择同意后进入指定app。

`DeepLink` 一方面流程上稍微长一些，另一方面存在scheme 被别人占用等问题，在Android6.0，有了 `AppLink`, 可以完美解决上述两个问题，与之对应的ios平台9.0上的加入的 `Universal Links`。 `AppLink` 在系统验证过服务端上配置的的证书(keystore)信息后，在6.0+上可以一步到达对应的应用，6.0以下系统降级为普通的 `DeepLink`，下面来看下怎么使用 `AppLink` 。

### 服务端配置

`AppLink` 需要将应用的keystore签名对应的sha哈希值配置到域名对应的指定目录，以本站域名为例，需要是以下地址:

```nohighlight
https://www.codeboy.me/.well-known/assetlinks.json
```

内容是固定的，配置下应用的package和对应签名的sha哈希即可。

```
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "me.codeboy.test",
      "sha256_cert_fingerprints": [
        "91:C1:DF:23:EB:37:91:5D:60:9E:FA:19:3F:BF:B1:4B:72:A5:97:AC:F2:16:17:66:8F:56:44:CB:3A:18:A3:39"
      ]
    }
  }
]
```

其中`sha256_cert_fingerprints`可以根据以下命令获取:

```nohighlight
keytool -list -v -keystore debug.keystore
```

### 客户端配置

客户端上需要给对应的Activity配置上intent-filter即可,  如下:

```xml
<intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data
                    android:host="www.codeboy.me"
                    android:scheme="https" />
</intent-filter>
```

- 对于参数上的解析，可以直接从intent中获取即可。
- 配置多个域名，需要每一个域名下对应的assetlinks.json均验证通过。

### AppLink测试

测试的方式有很多，可以编辑一条短信，也可以直接adb进行查看，这里通过adb验证:

```nohighlight
am start -a android.intent.action.VIEW -d https://www.codeboy.me
```

应用直接进入测试客户端。

> 如果配置多个域名，必须每个域名均校验通过，不然AppLink会降级为普通的DeppLink。

### 小结

AppLink使得用户的体验更好，有条件能支持的话还是支持一下比较好。




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
