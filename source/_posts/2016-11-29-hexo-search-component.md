---
layout: post
title: 'Hexo search组件'
date: '2016-11-29'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---

当前主流的静态博客有Jekyll和Hexo，之前的文章已经介绍了Jekyll中的搜索组件<[Jekyll search组件](/2016/01/18/jekyll-search-component/)>,本文来介绍下hexo博客中怎么添加搜索组件，组件项目地址[https://github.com/androiddevelop/hexo-search](https://github.com/androiddevelop/hexo-search).

### 截图

![jekyll-search.jpg](/img/jekyll-search.jpg)

双击ctrl或者点击右下角搜索图标查看效果

### 操作

1. 点击右下角图标进行搜索
2. 双击ctrl键进行搜索或关闭
3. 搜索页面点击右上角关闭按钮关闭搜索试图

### 加入步骤

1. 安装搜索插件:

	```
	npm install hexo-search-data-plugin --save
	```

2. 将search目录放至于hexo主题的`source`文件夹下，其中search目录结构如下:

		search
		├── cb-footer-add.html
		├── css
		│   └── cb-search.css
		├── img
		│   ├── cb-close.png
		│   └── cb-search.png
		└── js
		    ├── bootstrap3-typeahead.min.js
		    └── cb-search.js


3. 在当前主题的`layout/_partial/after-footer.ejs` 中的末尾加入 `cb-footer-add.html` 中的内容即可, 添加完毕后 `cb-footer-add.html` 文件可以删除。

> 如果主题不存在`after-footer.ejs`文件，也可以添加在`footer.ejs`中。


### 注意事项

1. `bootstrap3-typeahead.min.js` 的引入必须在`jquery.min.js`引入之后!

2. 默认联想8个，如果需要更多的话，请检索 `bootstrap3-typeahead.min.js` 中的**items:8**, 将**8**替换成自己需要的数值。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
