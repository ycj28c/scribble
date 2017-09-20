---
layout: post
title: Can We Do Pressure Test
disqus: y
share: y
---

> ps: All the numbers and cases in this page are fake number, just for example

# General Concept
Pressure test is based on performance test, which run a bunch of parallel requests targeting a function or a system work flow. The goals are:
1. Break down the system, get the test data such as TPS, PV
2. Find the system bottle neck
3. Show the result and see if boss or user satisfy with the current system capability
So it is best to run in production, but we has same mirror system stage, it is OK to test in stage.

# Pressure Test Precondition
1. Are we pressure test particular function or test the whole system
	* If test particular function, we only need to produce the pressure for that function
	* If test whole system, we need to simulate the general user behavior
2. Check the current user peer
user_session talbe: max login per minute is 7, max login per hour is 234 according to previous 6 month
Google Analytics: 842 active user per day in average
Sumologic: around 11 times of keywords "stormpath" per minute
3. Discuss the goal we want to achieve
for example: we want to handle max 30 users on time at same time, we want 50 users can visit this function  

# Pressure Test Metrics
Throughput: Request per seconds
TPR: Time Per Request, TPR = time cost of all request / concurrent user
The number of concurrent connection
PV: page view
...

# Feasibility Pressure Test For Your System
To answer this, we need to think about two parts of the pressure test: pressure producer and system monitor

### First, pressure producer
We have two system component require to do the pressure test:
1. Jboss
There are two ways to produce the pressue:
	* Manually make pressure, 30 or more people operate system together, produce pressure. This is the best way to simulate the real user behavior, but we need 30 people to test, however, if 30 person not able to break down system, we need to find more people.
	* Automation test, we can run the selenium UI test to produce pressure. One server can run multiple automation test, don't need humun intercept. The concern is the test server performance. One windowns VM maximun run 6-7 tests at the same time, to mockup 30 people, we need at least 5 server to run the tests, however, we only has 2 test server so far.
2. Tomcat
The tomcat is handling the API, use tools such as Jmeter or other test tools, we're able to create a large amount of API request in one node, which is able to make lots of pressure.

### Secondly, system monitor:
This is the pain part, when we produce the pressure outside, we also need to capture the system running metrics in the server side. It is hard to manually record the data during the pressure test. Here is the list of server we'll want to monitor:

| Name        		   | Monitor                                               |
| -------------------- |:-----------------------------------------------------:| 
| jboss/tomcat/database/redis server | we can directly use top command get metrics such as cpu, memory, swap, io, etc, but we don't have the tool to continues tracking and record the data change. |
| jboss      | need perfessional jboss monitor      | 
| tomcat | need perfessional tomcat monitor      |
| database | need perfessional postgres monitor      |
| network | usually system traffic should not be a problem for our network, we can check from ping or many tools|
| front end | if you don't have large front end resource and fancy javascript, the only time consume is download the css, javascript lib stuff, and front end runs in client side, it is not a performance issue for you.  |


# The Meaning Of Pressure Test For system
Is it meaning for the do the pressure test for system? Yes and no. "Yes" because it is always good to know how is our system performance, how much user we can handle. "No" because we don't have a big amount of client access daily, we don't has a feature which facing sudden large requests.

# Conclusion
In this case,

*Can we do the pressure test for system, the answer is yes.*

*Can we do the pressure test for system with current resource, the answer is no.*

The main reason we can't is because we don't have a good monitor tool which able to capture the performance of the Jboss/Tomcat/Postgres/Redis in realtime and persistent it, thus it is hard to identify the bottle neck and generate report. In addition to this, we don't have enough test servers to produce pressure, unless more people participate into the pressure test.

# Appendix(Chinese Version)

```
基本概念：
压力测试是基于性能测试，对某一个功能或者系统流程进行大量并行的请求，目的是
1）压爆系统，得出测试数据比如tps 2）找出瓶颈所在，是数据库啊，中间件，硬件之类 3）是否满意目前的压力指标，加入不满意需要优化系统后继续压测
正常情况最好是直接跑在production里面，但是我们求其次，跑在stage里面也是可以的

压测目标：
好，我们首先需要确认压测目标（输入和输出）：
1.确定是针对某一功能进行压测还是对全系统的压测，区别是我们的压力制造会有不同
2.根据各个工具确定目前的用户峰值
user_session_log: 每分钟最多的login是7人，一小时最大login是234
google analytics: 最多显示到hour的级别，一小时最多230多个用户，一分钟的话，而active user，只支持显示以天为单位级别的, 做个简单计算，大约16,837每30天，所以均值是842/8 = 105每小时，1.5每分钟
sumologic，搜索关键字stormpath，可以看到每分钟最多也就出现11次左右
所以我们的系统每分钟的在线人数绝对不超过20
3.再多方讨论确定我们需要达成的压测目标，比如需要能30个用户同时在线，50个用户能同时访问某功能等等

监控指标：
TPS, Throughput, pv，硬件指标等等

压力测试可行性：
能否对Insight进行压测，答案是肯定的。
那现有resource下能不能做，结论是不行，使用金字塔模型回答你：
1.压力制造端不够
1.1 insight方面的制造压力，有难度
1.1.1 一种是人力来压，比如30个人来一起点鼠标啊，互相伤害啊，这样需要很多人来测试，而且30个人未必能测出我们系统的临界点
1.1.2 使用工具来测，使用现有的UI测试制造压力，唯一问题是压测服务器性能不足，一台机器跑6-7个selenium测试已经是极限，我们总共就2台，显然是不够的。而且每个测试需要login，那么需要至少30个帐号呗
1.2 tomcat方面的制造压力，可以
1.2.1 通过jmeter或者其他一些api测试工具，目前tomcat内网无需登录，2台设备可以制造足够的压力

2.监控端不够
2.1 jboss端，-- 需要有效的工具
只能使用top监控硬件指标比如cpu，memory，network，swap等，但是无法监控jboss的指标，无法有效的记录测试曲线，需要有效的工具
2.2 tomcat端，-- 需要有效的工具
只能监控硬件指标，无法监控tomcat性能指标，无法记录测试数据，需要有效的工具
2.3 数据库端，-- 需要有效的工具
只能监控硬件指标，而且我无法登陆，无法监控tomcat性能指标，无法记录测试数据，需要有效的工具
2.4 前端，可以，可以手动排查性能，并非特别精确，但是
理论上不会是问题，至少到现在没发现由于资源读取速度（无CDN）和javascript性能造成的性能问题，但是无法监控每个前端性能，目前只能手工除非有好用的工具
2.5 网络瓶颈，可以
可以ping一ping，但是意义不大，通常在业务测试中就可以体现出来，可以无视

其实压测对于我们意义不大，原因
1.我们的日常访问量并不大
2.没有什么突发大量请求的功能，除了我们自己的script经常干死自己
3.用户对于性能的容忍度性对较大

除非某一个应用或者活动可能造成大规模的访问压力，我们才进行响应的压力测试
```