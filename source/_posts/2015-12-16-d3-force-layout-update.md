---
layout: post
comments: true
title: 'd3力学图(force layout)更新'
date: '2015-12-16'
header-img: "img/post-bg-web.jpg"
tags:
     - web
author: 'Codeboy'
---

d3是javascript的一个可视化库，可以制作很漂亮的表格等，其中有一个非常好玩的力学图，可以方便的进行拖拽等，但是关于更新的操作网上介绍的很少，下面介绍下关于力学图的更新，先看一个例子([http://example.codeboy.me/d3/force-layout.html](http://example.codeboy.me/d3/force-layout.html),点击一次下图后可以直接按回车键添加)：

<iframe src="https://example.codeboy.me/d3/force-layout.html" width="100%" height="500px" frameborder="0" scrolling="no"> </iframe>

绘制图形的方式基本上可以分为svg与canvas两种，两者各有优缺点，不对于以后屏幕越来越大，svg更加的有优势，并且svg可以很方便的进行事件交互。

下面看一下这个力学图具体实现：

### 整体代码
	
	<html>
	<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/layer/layer.min.js"></script>
    <script src="js/d3.min.js" charset="utf-8"></script>
    <title>d3 layout update</title>
	</head>
	<body style="height: 100%;">
	<div class="container" style="padding-left: 0; width: 100%;">
	    <div id="svg">
	    </div>
	</div>

	<script>
	    $(document).ready(function () {
	        var height = document.body.clientHeight;
	        var width = document.body.clientWidth;

	        var nodes_data = [{'name': '0'},
	            {'name': '1'},
	            {'name': '2'},
	            {'name': '3'},
	            {'name': '4'},
	            {'name': '5'},
	            {'name': '6'}];
	            
	        var edges_data = [{'source': 0, 'target': 1},
	            {'source': 0, 'target': 2},
	            {'source': 0, 'target': 3},
	            {'source': 0, 'target': 4},
	            {'source': 0, 'target': 5},
	            {'source': 0, 'target': 6}];

	        var color = d3.scale.category20();
	        var edgeWidth = 2;
	        var r = 40;
	        var svg = d3.select("#svg").append("svg")
	                .attr("width", width)
	                .attr("height", height);

	        var force = d3.layout.force()
	                .nodes(nodes_data)
	                .links(edges_data)
	                .size([width, height])
	                .linkDistance(200)
	                .friction(0.8)
	                .charge(-500)
	                .start();

	        //边
	        var links = svg.selectAll("line")
	                .data(edges_data)
	                .enter()
	                .append("line")
	                .attr("marker-end", "url(#arrow)")
	                .style("stroke", "#ccc")
	                .style("stroke-width", edgeWidth);
		//节点
	        var nodes = svg.selectAll("circle")
	                .data(nodes_data)
	                .enter()
	                .append("circle")
	                .attr("r", r)
	                .style("fill", function (d, i) {
	                    return color(i);
	                })
	                .on("click", function (d, i) {
	                    if (i == 0) {
	                        update();
	                    }
	                })
	                .call(force.drag);
		//标签
	        var nodes_labels = svg.selectAll("text")
	                .data(nodes_data)
	                .enter()
	                .append("text")
	                .attr("dx", function (d, i) {
	                    return -16 * (nodes_data[i].name.length);
	                })
	                .attr("dy", 5)
	                .attr("fill", "#fff")
	                .style("font-size", 16)
	                .text(function (d, i) {
	                    if (i == 0) {
	                        return "点我";
	                    }
	                    return "";
	                });

		//运动刷新
	        force.on("tick", function (d) {
	            links.attr("x1", function (d) {
	                var distance = Math.sqrt((d.target.y - d.source.y) * (d.target.y - d.source.y) +
	                        (d.target.x - d.source.x) * (d.target.x - d.source.x));
	                var x_distance = (d.target.x - d.source.x) / distance * r;
	                return d.source.x + x_distance;
	            }).attr("y1", function (d) {
	                var distance = Math.sqrt((d.target.y - d.source.y) * (d.target.y - d.source.y) +
	                        (d.target.x - d.source.x) * (d.target.x - d.source.x));
	                var y_distance = (d.target.y - d.source.y) / distance * r;
	                return d.source.y + y_distance;
	            }).attr("x2", function (d) {
	                var distance = Math.sqrt((d.target.y - d.source.y) * (d.target.y - d.source.y) +
	                        (d.target.x - d.source.x) * (d.target.x - d.source.x));
	                var x_distance = (d.target.x - d.source.x) / distance * r;
	                return d.target.x - x_distance;
	            }).attr("y2", function (d) {
	                var distance = Math.sqrt((d.target.y - d.source.y) * (d.target.y - d.source.y) +
	                        (d.target.x - d.source.x) * (d.target.x - d.source.x));
	                var y_distance = (d.target.y - d.source.y) / distance * r;
	                return d.target.y - y_distance;
	            });


	            nodes.attr("cx", function (d) {
	                return d.x;
	            }).attr("cy", function (d) {
	                return d.y;
	            });

	            nodes_labels.attr("x", function (d) {
	                return d.x;
	            });
	            nodes_labels.attr("y", function (d) {
	                return d.y;
	            });


	        });

		//用于产生不同颜色的节点
	        var colorIndex = 8;

	        //添加节点更新
	        function update() {
	            nodes_data.push({'name': 'xxx'});
	            edges_data.push({'source': 0, 'target': nodes_data.length - 1});

	            links = links.data(force.links());

	            links.enter()
	                    .append("line")
	                    .style("stroke", "#ccc")
	                    .style("stroke-width", 2);

	            links.exit().remove();

	            nodes = nodes.data(force.nodes());
	            nodes.enter().append("circle")
	                    .attr("r", 40)
	                    .style("fill", color(colorIndex++))
	                    .call(force.drag);

	            nodes.exit().remove();

	            force.start();
	        }

	        //回车事件
	        $(document).keydown(function(e) {
	            if(e.which == 13) {
	               update();
	            }
	        });
	    });

	</script>

	</body>
	</html>


### 更新讲解

更新部分只有 `update()`函数，更新的操作分为以下

1. 数据更新
2. 力学图重新加载数据
3. 追加对应的边与节点(enter)
4. 去除无用的元素(remove)
5. 执行 `force.start()` 操作 

只要按照顺序进行，新增的节点等就可以很好的添加。

### 例子说明

例子中有几点需要说明一下

1. `force.on("tick", function (d){...}) `中的计算用户绘制线条的时候只绘制两个圆之间的部分，当然这么做也便于添加箭头，也能较少一些其他的重叠操作。

2. `var nodes_labels = svg.selectAll("text")`中仅仅对第一个点进行了标注，用于提示点击操作，也可以对所有的点进行标注的。


### 总结

d3的github([https://github.com/mbostock/d3/wiki/Gallery](https://github.com/mbostock/d3/wiki/Gallery))上有很多的例子，大家可以找到自己喜欢的进行学习，同时也需要对svg有一定的学习，方便我们自己进行一些改进。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
