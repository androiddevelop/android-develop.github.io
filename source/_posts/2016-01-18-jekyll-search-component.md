---
layout: post
comments: true
title: 'Jekyll search组件'
date: '2016-01-18'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---

之前的文章<[给jekyll添加炫酷简洁的搜索](/2015/07/11/jekyll-search/)>中介绍了怎么给jekyll添加全局搜索功能，为了能够更快的加入搜索功能，现在已经将搜索功能提取出来，做成一个单独的组件，放在了[https://github.com/androiddevelop/jekyll-search](https://github.com/androiddevelop/jekyll-search).

### 截图

![jekyll-search.jpg](/img/jekyll-search.jpg)

双击ctrl或者点击右下角搜索图标查看效果

### 操作

1. 点击右下角图标进行搜索
2. 双击ctrl键进行搜索或关闭
3. 搜索页面点击右上角关闭按钮关闭搜索试图


### 加入步骤

1. 将search目录放至于博客根目录下，其中search目录结构如下:

		search
		├── cb-footer-add.html
		├── cb-search.json
		├── css
		│   └── cb-search.css
		├── img
		│   ├── cb-close.png
		│   └── cb-search.png
		└── js
		    ├── bootstrap3-typeahead.min.js
		    └── cb-search.js


2. 在 `_include/footer.html` 中的 `</footer>` 前加入 `cb-footer-add.html` 中的内容即可。 


### 注意事项

1.需要事先引入**jquery**与**bootstrap3(js与css文件)**框架，如果没有的话，操作如下:

在`_include/head.html` 中引入以下代码:

```
<link rel="stylesheet" href="//cdn.bootcss.com/bootstrap/3.3.6/css/bootstrap.min.css">
```
在`_include/footer.html` 中引入以下代码:

```
<!-- jQuery -->
<script src="//cdn.bootcss.com/jquery/2.2.2/jquery.min.js"></script>

<!-- Bootstrap Core JavaScript -->
<script src="//cdn.bootcss.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
```
> **请保证jquery.js的引入早于cb-search.js,即jquery引入的script标签更靠前。**

2.默认联想8个，如果需要更多的话，请检索 `bootstrap3-typeahead.min.js` 中的**items:8**, 将**8**替换成自己需要的数值。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
