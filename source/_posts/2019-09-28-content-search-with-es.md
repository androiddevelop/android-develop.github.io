---
layout: post
comments: true
title: 'ElasticSearch内容检索'
date: '2019-09-10'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

### 前言

`gitbook` 是目前流行的电子书制作工具，很多文档基于此构建，团队内部文档也是一样的。由于模块比较的多且复杂，各个模块的文档分别对应一个`gitbook`，职责明确了，但查找起来却麻烦很多，同时`gitbook` 查看文档的方式相对简单，不能根据文档相关性进行排序。

### 需求

- 多个gitbook文档能够提供统一查询入口
- 全文检索，根据相关性排序
- 提供文章访问热度
- 支持文章更新 
- 支持搜索结果关联词高亮

### 设计

当前用于文档搜索的引擎有不少，比较流行的有`solr`和`elasticSearch`, 考虑到后者功能强大，配置简单，决定使用`elasticSearch`(后文简称es)来存储文档，考虑到后续更灵活的扩展，使用`mysql`记录文档访问次数，用于文章热度的获取以及自动联想等。

系统包含以下几部分：

- gitbook爬虫

  从gitbook中获取数据，存储/更新到es中，同时将标题、url存储/更新到mysql中。

- es

  存储/更新文档。

- mysql

  记录用户访问频次，提供输入框自动联想。

### 技术点

- 中文分词

  使用[ik分词](https://github.com/medcl/elasticsearch-analysis-ik)插件进行。

- 存储到es中

  查询比较单一，没有使用es的The Java High Level REST Client，使用普通的查询完成通信。

- 查询优化

  考虑到标题相对比较短，并且比较简单，调整es查询时标题和内容的权重为1:2。

- 文档更新

  根据文档的变更，自动完成对文档修改、删除。

### 部署

参考[https://github.com/androiddevelop/DocSearch](https://github.com/androiddevelop/DocSearch)

### Demo页面
![](/img/doc-search-home.jpg)
![](/img/doc-search-result.jpg)

### 小结

结合了`elasticSearch`、`kibana(es数据展示)` 、`mysql`、`springboot`等完成了文档检索，可以在搜索引擎触及不到的地方(内网)部署一个，方便多个地方的文档聚合。




> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
