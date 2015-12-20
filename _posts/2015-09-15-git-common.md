---
layout: post
title: 'git常用操作'
date: '2015-09-15'
header-img: "img/home-bg.jpg"
tags:
     - git
author: 'Codeboy'
---

Git是一个开源的分布式版本控制系统，用以有效、高速的处理从很小到非常大的项目版本管理。 Git 是 Linus Torvalds 为了帮助管理 Linux 内核开发而开发的一个开放源码的版本控制软件。


### 复制完整项目

	git clone http://xxxxxx.xxx/xxxxx

### 检出分支(a)到本地(b)
	
	git checkout -b [my_local_branch] [my_remote_branch]

例如:把远程dev/1.0.0分支本地feature/1.0.0_my分支，

	git checkout -b feature/1.0.0_my dev/1.0.0

### 跟踪分支

	git branch --set-upstream-to=origin/[my_remote_branch] [my_local_branch]

或者

	git push -u origin [my_remote_branch]   //注意: 会直接push一次

例如: 把本地feature/1.0.0\_my分支管理到远程feature/1.0.0\_my分支，

	git branch --set-upstream-to=origin/feature/1.0.0_my feature/1.0.0_my 

因为之前所建分支是从dev/1.0.0中获取，所以本地feature/1.0.0_my与远程dev/1.0.0分支关联，执行git push(不加其他)的话，feature/1.0.0\_my分支的新代码将会上传至dev/1.0.0分支，所以我们需要重新关联分支，当然可以git push的时候指定远程的分支。

### 提交代码

	git add .     //也可以部分添加，此处添加所有变动文件
	
	git commit -am '注释说明'

### 增加tag

	git tag -a [tag_name] -m '注释说明'   //在需要的时候打tag

	git push origin [tag_name]  //上传tag到远程仓库

	git push origin --tags  //推送所有本地没有提交的tag

### 推送本地代码到远端

	git push  //推送到默认关联分支

	git push origin [remote_branch]  //推送到指定分支

### 切换分支

	git checkout [branch_name]

	git checkout -b [branch_name] //没有分支的话新建改分支

### 合并分支

	git merge [branch_name]   //将branch_name分支合到当前分支

### 获取远端更新

	git pull  //获取更新自动合并到本地分支
	
	git fetch //获取更新单不自动合到本地分支

### 查看本地分支

	git branch

### 查看远程分支

	git branch -r

### 删除分支

	git branch -d [branch_name]  //-d选项只能删除已经参与了合并的分支，对于未有合并的分支是无法删除的。如果想强制删除一个分支，可以使用-D选项

### 合并分支

	git merge [branch_name]  //将名称为[brand_name]的分支与当前分支合并

### 删除远程分支

	git push origin :[branch_name]

### 恢复某个文件

	git checkout -- [filename]  //注意,两个短横线左右都有空格
	
### 撤销本地上一次提交

	git reset --soft HEAD^ 
	
### 撤销远程最后两次提交
	
	git reset --soft HEAD~2 


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
