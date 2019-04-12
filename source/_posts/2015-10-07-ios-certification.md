---
layout: post
title: 'IOS8与9配置企业证书签名的应用'
date: '2015-10-07'
header-img: "img/post-bg-iphone.jpg"
tags:
     - ios
author: 'Codeboy'
---

ios8出来的时候，使用企业证书打出的包不能够下载，后来网上提供了一定的解决，在plist中的bundle id后面加上ios8fix，如下:

	 <key>bundle-identifier</key>
     <string>com.ahhailan.ios8fix</string>
     <key>bundle-version</key>
     <string>1.0</string>

ios9升级后，最大的变化要数用户必须手动的去信任企业证书，这个问题还算好，我们从之前的地址下载ios应用，发现下载不成功，每次都提示**无法下载应用程序**,看了网友的一些说解，ios9的plist中bundle id必与应用的必须相同，但是ios8的后面又需要加入ios8fix，这个依靠UA(UserAgent)来分发到不同的应用了。

简单的说明一下UserAgent：
	
	用户代理 User Agent，是指浏览器,它的信息包括硬件平台、系统软件、应用软件和用户个人偏好

UA查看网址[http://test.codeboy.me/ua.php](http://test.codeboy.me/ua.php)

例如我是用iphone 9.0.2系统打开的UA如下:

	Mozilla/5.0 (iPhone; CPU iPhone OS 9_0_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13A452 Safari/601.1		

我们只需对ios8的设备进行判断区分就行了，对不是ios8的设备跳转到另一个plist文件即可。 下面是javascript写的一个小例子。xxxx.plist是针对ios8的plist，xxxx2.plist是针对非ios8的plist，对UA进行判断后，跳转到不同的plist即可。

	<script>
	var downloadAddress = 'itms-services://?action=download-manifest&amp;url=https://xxxx.xx/xxxx.plist';
      if(navigator.userAgent.indexOf("OS 8") == -1){
            downloadAddress = downloadAddress.replace(/xxxx.plist/,"xxxx2.plist");
        }
	window.location = downloadAddress;
	</script>

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
