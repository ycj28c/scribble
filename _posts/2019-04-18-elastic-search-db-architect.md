---
layout: post
title: Elastic Search DB architect
disqus: y
share: y
categories: [Architecture, Search]
tags: [ElasticSearch]
---

//TODO English Version

本文將用中文，所有的research都是中文材料  

Introduce
---------
現在的數據庫種類很多，除了傳統數據庫，還有文檔數據庫，圖形數據庫，竪型數據庫等等，本文討論的是用Elastic Search作爲數據庫。我們知道Elastic Search是很廣汎應用的全文搜索，比較典型的例子就是Google的搜索bar（當然人家有自己的），同類的搜索引擎還有Solr之類。因爲ES也可以作爲一個數據庫，其高性能并行處理（砸錢堆機器），高可用性（砸錢堆機器），免費使用的特性讓他作爲一個數據庫也充滿亮點。

Replace Relation DB
-------------------
傳統數據庫適用與業務邏輯複雜，各種join，表于表之間聯係緊密，預算緊張的情況。但是如果財大氣粗，這些都可以用Elastic Search解決，而且ES的橫向擴展性很好，空間不夠，性能不佳的情況直接加入更多的Node和内存即可。這裏介紹下具體的轉換：

1. 数据的存放  
ES是基於lucene，大量的數據都是存放在内存中。ES會有很多的node，數據分佈應該通過一定的Hash算法，每個node均匀存放部分数值范围，load balance在每个node上，命中了直接返回，没命中则经过master来定位。是一種空間換時間的方式，每个shad存放所有需要的数据。

2. 數據分佈結構
比如有Organiztion和Person兩個Shad，雖然說這個Organization A裏頭有Person A，這個Person A也包含Organization A的信息，但是這確實兩個分開的Shad，不可能通過Join來聯合查詢。因爲複雜聯合速度會很慢，所以會將需要的數據盡量存放在1個index中去，需要好好的設計數據結構。

3. 等價數據查詢
ES基本上把关系型数据库的sql语言使用另外的算法再整了一邊，比如Group By:  
SQL的Group By
```
SELECT model,COUNT(DISTINCT color) color_count FROM cars GROUP BY model HAVING color_count > 1 ORDER BY color_count desc LIMIT 2;
```
对应Elasticsearch就是Terms Aggregation，即分桶聚合（也就是mapreduce之类的概念）
```
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
```
而COUNT(DISTINCT color) color_count需要使用一个指标类聚合Cardinality Bucket Filter实现having condition。ORDER BY color_count desc LIMIT 3是用Bucket Sort算法实现。所以，ES就是集群算法版本的数据库。 
 
關於關係型數據庫和ES查詢的轉換可以參考[Elasticsearch如何实现SQL语句中 Group By 和 Limit 的功能](https://segmentfault.com/a/1190000014946753)

ES vs Relation DB
-----------------
優點：   
* 高并发。实测es单机分配10g内存单实例，写入能力1200qps，60g内存、12核CPU起3个实例预计可达到6000qps。 
* 横向Scale方面做的很出色，满足大数据下实时读写需求，无需分库（不存在库的概念）。数据之间无关系，这样就非常容易扩展。
* 速度快，ES直接返回數據，没有relational db那些步骤，基本就是IO的速度。

缺點：  
* es没有事务，而且是近实时。
* 吃硬件，几乎靠吃内存提高性能，成本也比傳統数据库高。
* 传统数据的多表关联操作，在es中处理会非常麻烦。比如有4，5张表想要join下然后group by order by就不容易搞定。原因在于：传统数据库设计的初衷在于特定字段的关键词匹配查询；而es倒排索引的设计更擅长全文检索。
* ES的权限这块还不完善。
* 浪費空間，ES是基于Lucene开发的，它的许多局限从根本上都是由Lucene引入的。例如，为了提高性能，Lucene会将同一个term重复地index到各种不同的数据结构中，以支持不同目的的搜索，基于你选用的分析器，最终index数倍于原本的数据大小是有可能的。内存方面，ES的排序和聚合（Aggregation）操作会把几乎所有相关不相关的文档都加载到内存中，一个Query就可以很神奇地吃光所有内存
* 最逆天的是，mapping不能改，需求变化时候用es你会想死，数据量多你能想像一下几亿的数据慢慢scan然后全部重建的痛苦吗。
* 因为使用桶聚合，不知道桶有多大，数据太多就爆了，导致OOM，全靠花钱堆。但是因为快，所以oom不一定发生。  

此外，ES团队不推荐完全采用ES作为主要存储，缺乏访问控制还有一些数据丢失和污染的问题，建议还是采用专门的 DB存储方案，然后用ES来做serving。可以用ES + HDFS主要用来做查询等，但速度没达到毫秒级，几十亿数据查询3秒左右，ES官方说是毫秒级 但没说数据量级别。elasticsearch是分布式的存储，比如你有5个分片，你的数据是分散在5个分片实例上的，但凡是分布式数据存储，使用join等关联性操作就会复杂化，因为你无法确保需要关联的数据在同一个分片上，因此elasticsearch引入了parent_children数据关系类型(可以做到join等操作)；数据库分库分表也是需要考虑数据存储路由规则的,另外索引机制，使得不同类型数据在同一index下，会造成不必要的搜索压力。

ES vs Other NoSql
-----------------

关于nosql种类：  
* 键值(Key-Value)存储数据库： redis，voldemort
* 列存储数据库： Cassandra，Hbase，Riak。 这部分数据库通常是用来应对分布式存储的海量数据（大表）。键仍然存在，但是它们的特点是指向了多个列。这些列是由列家族来安排的。
* 文档型数据库： couchDB，MongoDb。 文档型数据库可以看作是键值数据库的升级版，允许之间嵌套键值。而且文档型数据库比键值数据库的查询效率更高。
* 图形数据库： Neo4J, InfoGrid, orientDb。 connection使用graph db來做有優勢。

優點(和MongoDB比較）：    
* 免費使用,當初mongoDB太贵，所以用ES，目前还在用orientDb，neo4j（connection都是用graph db做的，有优势）
* 容错能力比mg强。比如1主多从，主片挂了从片会自动顶上（硬件上）
* 支持较复杂的条件查询，group by、排序都不是问题（mongo不行）
* ES还多出个全文索引功能，当然mongo3也有，但和es比就是个玩笑。es现在更多的也被归入nosql一族了而非ir系统

缺點：  
* MongoDB比較簡單，輕量級，易用


Addition Resource
-----------------
关于ElasticSearch-Hadoop和家族，简单来说，Hadoop还是Hadoop，Elasticsearch还是Elasticsearch，而Elasticsearch-Hadoop在中间用来连接这两个系统，大量的原始数据可以存放在Hadoop里面，通过Elasticsearch—Hadoop可以调用Hadoop的Map-Reduce任务来创建elasticsearch的索引，数据进入elasticsearch之后，就可以使用elasticsearch的搜索特性来进行更加高级的分析，比如基于Kibana来作快速分析。

Elasticsearch支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和amazon的s3云存储服务。HDFS就是分布式文件存储系统，在读写一个文件时，当我们从 Name nodes 得知应该向哪些 Data nodes 读写之后，我们就直接和Data node 打交道，不再通过Name nodes。

當然這些年由於云比如AWS，Azure的興起，數據庫也走云服務了，如果真的不差錢，完全可以直接用云服務，省去了基礎設施的顧慮。

Reference
---------
[5分钟深入浅出 HDFS](https://zhuanlan.zhihu.com/p/20267586)  
[elasticsearch（lucene）可以代替NoSQL（mongodb）吗？](https://www.zhihu.com/question/25535889)  
[Elasticsearch--- mapping是什么](https://www.jianshu.com/p/7cf6af033823)  
[Elasticsearch如何实现SQL语句中 Group By 和 Limit 的功能](https://segmentfault.com/a/1190000014946753)  
[一文读懂非关系型数据库（NoSQL）](https://www.jianshu.com/p/2d2a951fe0df)  