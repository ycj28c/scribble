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



ES基本上把关系型数据库的sql语言使用另外的算法再整了一般，比如group by，对应Elasticsearch就是Terms Aggregation
SELECT model,COUNT(DISTINCT color) color_count FROM cars GROUP BY model HAVING color_count > 1 ORDER BY color_count desc LIMIT 2;
当然，两者都是在内存中完成，查询的区别没有这么大，集群算法版本的数据库
GET cars/_search
{
  "size": 0,
  "aggs": {
    "models": {
      "terms": {
        "field": "model.keyword"
      },
      "aggs": {
        "color_count": {
          "cardinality": {
            "field": "color.keyword"
          }
        },
        "color_count_filter": {
          "bucket_selector": {
            "buckets_path": {
              "colorCount": "color_count"
            },
            "script": "params.colorCount>1"
          }
        },
        "color_count_sort": {
          "bucket_sort": {
            "sort": {
              "color_count": "desc"
            },
            "size": 2
          }
        }
      }
    }
  }
}
Group By color 使用的是Terms Aggregation，即分桶聚合（也就是mapreduce之类的概念）
COUNT(DISTINCT color) color_count需要使用一个指标类聚合 Cardinality 
Bucket Filter实现having condition
ORDER BY color_count desc LIMIT 3是用Bucket Sort算法实现

需要很好的设计，
不好：
es没有事务，而且是近实时。成本也比数据库高，几乎靠吃内存提高性能。最逆天的是，mapping不能改。
ES团队不推荐完全采用ES作为主要存储，缺乏访问控制还有一些数据丢失和污染的问题，建议还是采用专门的 DB存储方案，然后用ES来做serving。
我们项目就用的ES，说是尝试新技术。结果是当你的数据本身就是关系型数据时，ES会把你搞死。
他们用的是ES + HDFS 主要用来做查询等 但速度没达到毫秒级 几十亿数据查询3秒左右 我也在研究如何能够达到毫秒级 ES官方说是毫秒级 但没说数据量级别 如果有知道的还请不吝赐教 Oracle优化后查询几十亿能做到毫秒级也可。
传统数据的多表关联操作，在es中处理会非常麻烦。原因在于：传统数据库设计的初衷在于特定字段的关键词匹配查询；而es倒排索引的设计更擅长全文检索。
有4，5个表想要join下，你可以轻松搞定吗？有4，5张表想要join下然后group by order by 
elasticsearch是分布式的存储，比如你有5个分片，你的数据是分散在5个分片实例上的，但凡是分布式数据存储，使用join等关联性操作就会复杂化，因为你无法确保需要关联的数据在同一个分片上，因此elasticsearch引入了parent_children数据关系类型(可以做到join等操作)；数据库分库分表也是需要考虑数据存储路由规则的,另外索引机制，使得不同类型数据在同一index下，会造成不必要的搜索压力。
个人以为Elasticsearch作为内部存储来说还是不错的，效率也基本能够满足，在某些方面替代传统DB也是可以的，前提是你的业务不对操作的事
性务有特殊要求；而权限管理也不用那么细，因为ES的权限这块还不完善。
ES是基于Lucene开发的，它的许多局限从根本上都是由Lucene引入的。例如，为了提高性能，Lucene会将同一个term重复地index到各种不同的数据结构中，以支持不同目的的搜索，基于你选用的分析器，最终index数倍于原本的数据大小是有可能的。内存方面，ES的排序和聚合（Aggregation）操作会把几乎所有相关不相关的文档都加载到内存中，一个Query就可以很神奇地吃光所有内存
mapping是不可变！？？？？当需求经常变时候最好用mongo。需求变化时候用es你会想死，数据量多你能想像一下几亿的数据慢慢scan然后全部重建的痛苦吗。http://127.0.0.1:9200/b2bware，这里的b2bware就是mapping， GET /website/article/_search?q=2017 这个路径/website/article/就是mapping
因为使用桶聚合，不知道桶有多大，数据太多就爆了，导致OOM，全靠花钱堆。但是因为快，所以oom不一定发生。
空间浪费，一次返回一整个document，业务逻辑中也需要时间去单独提取的。

好的
性能不错，高并发。实测es单机分配10g内存单实例，写入能力1200qps，60g内存、12核CPU起3个实例预计可达到6000qps。
满足大数据下实时读写需求，无需分库（不存在库的概念）.数据之间无关系，这样就非常容易扩展。
ES确实在横向Scale方面做的很出色
ES直接返回 没有relational db那些步骤 基本就是IO的速度
NoSQL在不太影响性能的情况下，就可以方便地实现高可用的架构。比如Cassandra、HBase模型，通过复制模型也能实现高可用。??



和其他nosql比较
--------------
好的
mongo太贵，所以用ES，目前还在用orientDb，neo4j（connection都是用graph db做的，有优势）
容错能力比mg强。比如1主多从，主片挂了从片会自动顶上（硬件上）
支持较复杂的条件查询，group by、排序都不是问题（mongo不行）
es还多出个全文索引功能，当然mongo3也有，但和es比就是个玩笑。es现在更多的也被归入nosql一族了而非ir系统

不好：

关于nosql种类
键值(Key-Value)存储数据库：redis，voldemort
简单

列存储数据库： Cassandra，Hbase，Riak
这部分数据库通常是用来应对分布式存储的海量数据（大表）。键仍然存在，但是它们的特点是指向了多个列。这些列是由列家族来安排的。

文档型数据库： couchDB，MongoDb
文档型数据库可以看作是键值数据库的升级版，允许之间嵌套键值。而且文档型数据库比键值数据库的查询效率更高。

图形数据库:Neo4J, InfoGrid


关于ElasticSearch-Hadoop和家族
-------------------------------
简单来说，Hadoop还是Hadoop，Elasticsearch还是Elasticsearch，而Elasticsearch-Hadoop在中间用来连接这两个系统，大量的原始数据可以存放在Hadoop里面，通过Elasticsearch—Hadoop可以调用Hadoop的Map-Reduce任务来创建elasticsearch的索引，数据进入elasticsearch之后，就可以使用elasticsearch的搜索特性来进行更加高级的分析，比如基于Kibana来作快速分析。

elasticsearch支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和amazon的s3云存储服务

HDFS就是分布式文件存储系统，在读写一个文件时，当我们从 Name nodes 得知应该向哪些 Data nodes 读写之后，我们就直接和 Data node 打交道，不再通过Name nodes.

Reference
---------

[5分钟深入浅出 HDFS](https://zhuanlan.zhihu.com/p/20267586)
[elasticsearch（lucene）可以代替NoSQL（mongodb）吗？](https://www.zhihu.com/question/25535889)
[Elasticsearch--- mapping是什么](https://www.jianshu.com/p/7cf6af033823)
[Elasticsearch如何实现SQL语句中 Group By 和 Limit 的功能](https://segmentfault.com/a/1190000014946753)
[一文读懂非关系型数据库（NoSQL）](https://www.jianshu.com/p/2d2a951fe0df)