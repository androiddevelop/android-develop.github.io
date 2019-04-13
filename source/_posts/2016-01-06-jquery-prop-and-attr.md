---
layout: post
comments: true
title: 'Jquery操作单选框选中状态'
date: '2016-01-06'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---

前端开发中经常使用到单选框(radio)与多选框(checkbox)组件，需要对组件的状态进行设置和读取，下面看一段网上流行的操作代码：

	<div class="cb-container">
    <input type="radio" class="cb-radio" id="r1" name="rd" value="left"/>
    <input type="radio" class="cb-radio cb-gap2" id="r2" name="rd" value="right"/>
    <button id="btn" type="button" class="btn btn-primary cb-gap">left</button>
    <button id="btn2" type="button" class="btn btn-primary cb-gap">right</button>
	</div>
	<script type="text/javascript">
	    $(document).ready(function () {
	        var radios = $(".cb-radio");
	        $("#btn").click(function () {
	            radios.eq(0).attr("checked", true);
	            radios.eq(1).attr("checked", false);
	        });
	        $("#btn2").click(function () {
	            radios.eq(0).attr("checked", false);
	            radios.eq(1).attr("checked", true);
	        });
	    });
	</script>

可以点击下面的单选框查看效果，整体代码可以在[https://example.codeboy.me/jquery/radio_operate_0.html](https://example.codeboy.me/jquery/radio_operate_0.html)查看。

<iframe src="https://example.codeboy.me/jquery/radio_operate_0.html" width="100%" height="80px" frameborder="0" scrolling="no"> </iframe>

测试后发现 `left` 与 `right` 按钮只有第一次点击后才能选择，之后点击后单选框的选中状态将一直处于未选中状态。

### 为什么为出现这种现象呢？

jquery中同时提供了attr()与prop()方法对属性进行获取，但是还是有一定的区别，看一下[官网](http://api.jquery.com/prop)的解释:

>The difference between attributes and properties can be important in specific situations. **Before jQuery 1.6**, the .attr() method sometimes took property values into account when retrieving some attributes, which could cause inconsistent behavior. **As of jQuery 1.6**, the .prop() method provides a way to explicitly retrieve property values, while .attr() retrieves attributes.

>For example, selectedIndex, tagName, nodeName, nodeType, ownerDocument, defaultChecked, and defaultSelected should be retrieved and set with the .prop() method. **Prior to jQuery 1.6**, these properties were retrievable with the .attr() method, but this was not within the scope of attr. These do not have corresponding attributes and are only properties.

可以看出，官网给出了明确的解释，在jquery1.6之后，对于checked，selected等进行状态改变时，需要使用的是prop()而不是attr(),于是我们我们将之前代码中的attr改变为prop后，可以看到运行效果如下，代码可以在[https://example.codeboy.me/jquery/radio_operate_1.html](https://example.codeboy.me/jquery/radio_operate_1.html)查看。

<iframe src="https://example.codeboy.me/jquery/radio_operate_1.html" width="100%" height="80px" frameborder="0" scrolling="no"> </iframe>

点击测试后,看到可以看到选择了。

### 获取选中状态

已经成功的可以设置单选框的状态了，下面就是判断到底单选框是否选中了，这个也同样是使用prop().

	$("#r1").prop();
	
上面代码将会返回 `true` 或 `false`， 进而判断是哪个单选框被选中的。

如果只是需要获取单选框选中元素的value值，即上面代码中的left与right属性，那边执行使用下面代码即可:

	$(".cb-radio:checked").val();

上面代码将返回 `left` 或 `right` 或 `undefined`，也即选中元素的值，如果都没选中的话返回undefined。例子见下，代码可以在[https://example.codeboy.me/jquery/radio_operate_2.html](https://example.codeboy.me/jquery/radio_operate_2.html)查看。

<iframe src="https://example.codeboy.me/jquery/radio_operate_2.html" width="100%" height="80px" frameborder="0" scrolling="no"> </iframe>

点击测试后, 右侧文本框将会限制选中元素的value值了。


> 如有任何知识产权、版权问题或理论错误，还请指正。
> 
> 转载请注明原作者及以上信息。

