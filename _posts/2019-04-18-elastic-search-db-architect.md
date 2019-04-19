---
layout: post
title: Elastic Search DB architect
disqus: y
share: y
categories: [Architecture, Search]
tags: [ElasticSearch]
---

//TODO

1.关于数据的存放
2.org person 即使内容有关联，但是shad之间没关联
3.空间换时间，每个shad存放所有需要的数据
4.要好好设计
5.有orgid，直接返回org快，但是通过org name之类返回就不会那么快？因为遍历的关系
6.es会有很多node，每个node单独存放部分数值范围，load balance在每个node上，命中了直接返回，没命中则经过master来定位

。。。。

Reference
---------
