---
layout: post
title: Scalability For Dummies After Reading
disqus: y
share: y
categories: [Devops, Architecture]
tags: [Scale]
---

After Reading
-----------
文章比较老了，属于扩展化的鼻祖文章，不过可以借鉴下思想，查漏补缺。

1.[Scalability for Dummies - Part 1: Clones](http://www.lecloud.net/post/7295452622/scalability-for-dummies-part-1-clones)

关键点：
* 中央化用户关联数据
文中提到比如session或者images之类都需要中央化，避免多个应用服务器的数据同步性问题，可以通过disc和memory的方式中央化。比如说使用额外的数据库存储或者永久化的cache比如Reids。

单独的数据库可以保证用户的一致性了，但是怎么保证这个单独数据库的扩展性呢？我们就要使用集群，但是用了集群又出现了一致性问题，难道这个问题就这么循环了？不是这，这些数据库可以使用统一的disk mount，而这些disk mount 可以使用raid1，raid10，raid5之类磁盘阵列，可以保证一致性和避免single point fail。这里的Memory可以是Redis之类的内存cache，当然我们也可以采用CDN之类的服务商和各种cloud服务API，如今的云服务很多，都可以充当一致性存储。

* 部署一致化
文中提到了当使用多个web服务器的load balance，必须保证code的一致性，比如使用Capistrano来同步应用。

当然我们现在有更多的devops工具，比如chef和docker等，通过Maven打包和规范的版本控制，比如[Gitflow](https://blog.axosoft.com/gitflow/)，我们可以保证code的一致行。[Do We Need Both Capistrano and Chef?](http://codefol.io/posts/why-do-we-need-both-capistrano-and-chef)提到了几个工具的区别。

2.[Scalability for Dummies - Part 2: Database](http://www.lecloud.net/post/7994751381/scalability-for-dummies-part-2-database)

关键点：
* 当数据库不堪重负，比较直接的就是增加硬件配置。
文中提到的第一种就是增加RAM，增加主备切换，还有一些sharding，denormalization，SQL tuning的技术。当前都是物理设备，需要实实在在的资金投入的。

我们当然也可以直接使用云数据库比如AWS数据库进行数据的存储，一切都是trade off，采取比较节省和合理的方案。比较常见的就是新应用初期，无法预知项目未来进展，拿就先部署上容易扩展的云上，用户服务量稳定后再移植回本地本服务节省运营成本。同时数据库也有一系列的优化比如partition，将不同类型数据归类到某个数据库服务器，或者读写分离之类都是可以考虑的优化方案。

* 区分业务应用，使用不同的数据库。
文中提到非规则化数据使用NoSQL来进行存储比如MongoDB或者CouchDB，当然在应用的code上得做出相应的修改。

关键是应用场景，推荐系统，分析系统等都很适合NoSQL，因为NoSQL总会返回一个最接近搜索条件的值。通常适合非实时非复杂业务关联的场景，其实Elastic Search之类也可以当做一个NoSQL，比如返回一个人的profile就可以使用ES，可以比数据库快的多的返回数据。

3.[Scalability for Dummies - Part 3: Cache](http://www.lecloud.net/post/9246290032/scalability-for-dummies-part-3-cache)

关键点：
* 过多的数据库query造成严重的性能瓶颈，应采用cache辅助
文中提高使用Memcached或者Redis之类的in-memory cache，但是不要做file-based caching，因为会造成大量的克隆。

* cache数据库查询query的方式
文中提到的key就是查询query，value就是这个查询的结果。这个技术主要问题是过期问题，存储复杂的大query，个别query部分比如age=1和age=2和age<3都会需要不同的key。而且一旦该query发生微小的更改，所有关联的key都需要更改，这是非常痛苦的。

* cache对象的方法
文中提到这是比较推荐的方式，cache“猫”，“三明治”之类的基础对象比cache“黄色的猫今天吃了三明治“更清晰和节省空间。这需要合理的normalize代码结构和存储结构。一些比较常见的object cache例子：用户session，已经编译好的blog文章，比较活跃的数据，用户关联（需要大量计算结果）

cache也是不应该滥用的，因为虽然理论上我们可以无限的增加内存，而且Redis之类的cache本身也是支持集群的。但是都是投入，而且是需要定时进行数据更新的。在每次清理下cache后，再次加载的数据会很慢，而如果pre cache数据，则大量的cache数据也同样需要大量的处理时间。所以需要合理的设计

4.[Scalability for Dummies - Part 4: Asynchronism](http://www.lecloud.net/post/9699762917/scalability-for-dummies-part-4-asynchronism)

关键点：
* 预先准备好结果，直接展示跳过大量处理时间
文中提到比如website，预先将大量的动态网页编译为HTML静态页面，还有一些复杂计算结果通过scripts cronjob之类预先计算好结果。具体的案例比如编译好HTML并且通过自动化script上传到AWS S3或者Cloudfront，每次直接从S3读取页面，这样就可能极大改善网站响应速度。

中间件比如Tomat，Jboss，Weblogic等干的就是这个HTML编译工具，不过是启动时候和动态加载的。典型的Craglist也是预编译HTML的典型，当然也有缺点，那就是一旦修改比如头文件，全部编译好的HTML全部都得重新编译，导致了无法灵活的修改网站样式和同步性隐患。

* 异步化处理
文中提高了在前端发出一个复杂请求后，将进入queue中，当这个请求计算一完成，就直接将结果发回前端，无需额外等待时间。文中提到了RabbitMQ，ActiveMQ和Redis list技术。

这个类似于多线程了，AJAX之类的技术了，各个部分独立发出请求，完成后直接进行响应。需要前端异步代码和后端的多线程以及队列同时进行，当然现在通过中间件比如Tomcat和Web Framework比如Spring都帮程序员做好了，我们直接用即可。

Overall
---------
看完了文章，总的来说这四篇文章比较像鸡汤文，给了汤没给勺子，文中谈到了不少看起来正确但也是理所当然的理论，即使在正常的网站维护中都会自然而然的应用到这些技术，营养不大。不过这是2011年的文章，在当时应该也是比较有前瞻性了。