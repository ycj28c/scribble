---
layout: post
title: When Using MQ
disqus: y
share: y
categories: [Architecture]
tags: [MQ]
---

Knowledge about MQ(Message Queue), what senario to use MQ, the difference between MQ products and thinking of scale.

When Use MQ
-----------
1.解耦，和业务分离，往mq一写，其他service自己随便取。 
```
# 传统模式
# 系统间耦合性太强，如上图所示，系统 A 在代码中直接调用系统 B 和系统 C 的代码，如果将来 D 系统接入，系统 A 还需要修改代码，过于麻烦！
系统A <-- 接入 -- 系统B
      <-- 接入 -- 系统C
	  ? 系统D （系统D也想接入，但是要接入系统A需要改代码）

# MQ模式
# 将消息写入消息队列，需要消息的系统自己从消息队列中订阅，从而系统 A 不需要做任何修改。
系统A --写入--> 消息队列 <--- 系统B
                        <--- 系统C
						<--- 系统D
```
2.需要异步发送消息。或者网络不通场景。
```
# 传统模式(120ms)
# 一些非必要的业务逻辑以同步的方式运行，太耗费时间。
用户1 --> 系统B(40ms) --> 系统C(40ms) --> 系统D(40ms)

# MQ模式
# 将消息写入消息队列，非必要的业务逻辑以异步的方式运行(C/D同时读)，加快响应速度 45ms
用户1 --> 系统B(40ms) --写入--> 消息队列(耗时5ms) <--订阅-- 系统C
                                                <--订阅-- 系统D
```
3.消峰，在生产过多可以在queue里面待着慢慢消费，典型就是秒杀业务。  
```
# 传统模式(120ms)
# 并发量大的时候，所有的请求直接怼到数据库，造成数据库连接异常
用户1 --写入--> 系统A --写入--> 数据库
用户2 --写入-->                        
用户3 --写入-->		

# MQ模式
# 系统A慢慢的按照数据库能处理的并发量，从消息队列中慢慢拉取消息。在生产中，这个短暂的高峰期积压是允许的
用户1 --写入--> 消息队列 <--按照业务规则读取-- 系统A --> 数据库
用户2 --写入-->                        
用户3 --写入-->				
```
4.最终一致性，mq保证了数据的准确到达。  
5.如果有日志采集功能，肯定是首选 kafka了。  

引入MQ的缺点：  
1.系统可用性降低：你想啊，本来其他系统只要运行好好的，那你的系统就是正常的。现在你非要加个消息队列进去，那消息队列挂了，你的系统不是呵呵了。因此，系统可用性降低。  
2.系统复杂性增加：要多考虑很多方面的问题，比如一致性问题、如何保证消息不被重复消费，如何保证保证消息可靠传输。因此，需要考虑的东西更多，系统复杂性增大。  

MQ Products
-----------
* ZeroMQ
* 推特的Distributedlog
* ActiveMQ：Apache旗下的老牌消息引擎
* RabbitMQ、Kafka：AMQP的默认实现。
* RocketMQ
* Artemis：Apache的ActiveMQ下的子项目
* Apollo：同样为Apache的ActiveMQ的子项目的号称下一代消息引擎
* 商业化的消息引擎IronMQ
* 以及实现了JMS(Java Message Service)标准的OpenMQ。

传统的queue就是点对点，经典生产者消费者，你发我收。新的mq比如Kafka主要使用的发布/订阅模式（pub/sub），可以有多个订阅者。  
很多传统queue是不持久化数据，发完就删除。  

MQ Difference
-------------
模式：Kafka是发布/订阅模式（pub/sub），可以有多个订阅者，传统queue大多点对点，经典生产者消费者。
持久化：Kafka是持久化，不会一发送就删除。
高可用：Kafka是分布式，所以不怕宕机。
消息重发：支持at least once，at most once机制。
吞吐量：kafka的TPS大，可以多个Producer和多个Consumer。
顺序消息：Kafka支持（每个分区内部是有序的），传统queue大部分不支持。
消息确认：Kafka支持ack确定（0写了就算成功，1写入master就成功，all全分区写入才成功）模式。
消息回溯：Kafka支持消息回溯offset控制，传统queue大部分不支持。
消息重试：Kafka不支持，但是可以实现（通过分区offset位置回溯），传统queue大部分不支持。
并发：Kafka高并发，可以多个Producer和多个Consumer，这个和吞吐量是一样的。

可以看出Kafka很多场景可以代替传统queue，但是也有缺点:
1.重复消息。Kafka只保证每个消息至少会送达一次（根据设置），虽然几率很小，但一条消息有可能会被送达多次。
2.消息乱序。虽然一个Partition内部的消息是保证有序的，但是如果一个Topic有多个Partition，Partition之间的消息送达不保证有序。
3.复杂性。Kafka需要zookeeper 集群的支持，Topic通常需要人工来创建，部署和维护较一般消息队列成本更高。
4.消费失败不支持重试，不支持事务消息，不支持定时消息，不支持不支持消息查询。
5.Kafka单机超过64个队列/分区，Load会发生明显的飙高现象，队列越多，load越高，发送消息响应时间变长。所以不太适合在线业务使用，主要用户大数据场景。

Conclusion
-----------
如果是一个不大的系统，不一定要用消息队列引擎，库就能解决。如果严谨的要求不丢数据，用传统的queue（RabbitMQ）更好一些。

1.Kafka  
```
Kafka主要特点是基于Pull的模式来处理消息消费，追求高吞吐量，一开始的目的就是用于日志收集和传输，适合产生大量数据的互联网服务的数据收集业务。  

大型公司建议可以选用，如果有日志采集功能，肯定是首选kafka了。  
```

2.RocketMQ
```
天生为金融互联网领域而生，对于可靠性要求很高的场景，尤其是电商里面的订单扣款，以及业务削峰，在大量交易涌入时，后端可能无法及时处理的情况。

RoketMQ在稳定性上可能更值得信赖，这些业务场景在阿里双11已经经历了多次考验，如果你的业务有上述并发场景，建议可以选择RocketMQ。
```

3.RabbitMQ
```
RabbitMQ :结合erlang语言本身的并发优势，性能较好，社区活跃度也比较高，但是不利于做二次开发和维护。不过，RabbitMQ的社区十分活跃，可以解决开发过程中遇到的bug。

如果你的数据量没有那么大，小公司优先选择功能比较完备的RabbitMQ。
```

分布式的情况，肯定就是kafka了，国外不怎么用RocketMQ吧。

Message Queue Thinking
---------------------
1.如何保证消息队列高可用？  
通过集群机制，master-slave，还有zookeeper管理的集群等方式

2.如何保证消息不被重复消费？  
首先queue本身有一些at most once之类的设置，此外在queue基础上进行处理，比如在后面数据库端有key的设置，那么如果有重复数据就不会被插入。

3.如何保证消费的可靠性传输？ 
不同的MQ处理机制不一样， 
1）生产者丢数据：producer需要ACK验证，Kafka则是通过follower和leader的同步避免丢失。  
2）消息队列丢数据：通过数据持久化避免丢失，重启后依然存在。  
3）消费者丢数据：通过ACK确认已经消费。  

4.如果保证消息的顺序性？  
在高吞吐量的情况下难以保证，kafka也就是同一个partition内部有序，topic不能保证。

Reference
---------
[Kafka，Mq，Redis作为消息队列使用时的差异？](https://www.zhihu.com/question/43557507)  
[高并发架构系列：Kafka、RocketMQ、RabbitMQ的优劣势比较](https://blog.csdn.net/weixin_34197488/article/details/89544910?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control)  
[一个用消息队列 的人，不知道为啥用 MQ，这就有点尴尬](https://learnku.com/articles/36282)  



