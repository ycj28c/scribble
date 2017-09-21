---
layout: post
title: Redis Troubleshoot Command
disqus: y
share: y
categories: [Database]
---

Purpose
-------------------------
List some useful Redis command for maintenance, help us debug the Redis issue which cause the Insight slow (p4p slow, new TCR slow etc.)

The common Reids cache missing situation:
+ Program bug or human mistake
+ Keys being evicted by LRU because too much client buffer memory
+ Master Redis restart cause all keys missing
+ Network zone problem may lead the redis data write issue in short time
+ Master/Slave Redis copy data issue, cause data lost after switch master/slave
+ Key expired, being clean

Basic Server Check(Linux)
-------------------------

Redis Connection
```shell
$ top
# check the Load/CPU/Memory/Swap/Network/Disk Usage, make sure they are normal
```

Redis Network Check
-------------------------

+ Redis Connection
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> ping
# If Redis not connected, cache will not work
# we have Jenkins job run ping command make sure redis works: https://build.equilar.com/production/view/Redis/
```

+ Redis Latency
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 –latency
# If network bad, cause long latency, will cause Redis response slow
#
# For example:
# So when we ran the command redis-cli --latency -h 127.0.0.1 -p 6379 Redis enters into a special mode in which it continuously samples latency (by running PING).
# Now let's breakdown that data it returns: min: 0, max: 15, avg: 0.12 (2839 samples)
# What's (2839 samples)? This is the amount of times the redis-cli recorded issuing the PING command and receiving a response. In other words, this is your sample data. In our example we recorded 2839 # requests and responses.
# What's min: 0? The min value represents the minimum delay between the time the CLI issued PING and the time the reply was received. In other words, this was the absolute best response time from our sampled data.
# What's max: 15? The max value is the opposite of min. It represents the maximum delay between the time the CLI issued PING and the time the reply to the command was received. This is the longest response time from our sampled data. In our example of 2839 samples, the longest transaction took 15ms.
# What's avg: 0.12? The avg value is the average response time in milliseconds for all our sampled data. So on average, from our 2839 samples the response time took 0.12ms.
# Basically, higher numbers for min, max, and avg is a bad thing.
```

Redis Info Overview
-------------------------

+ Redis Info
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> info
# Check https://redis.io/commands/INFO for detail description for each Redis info.
```

Redis Cache Debug
-------------------------

+ Total Keys
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> DBSIZE
# (integer) 343585
# The total count of keys are 342112
```

+ Hit Ratio
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> info
# Find
# keyspace_hits:12141853
# keyspace_misses:36914043
# Then then cache hit rate is: 12141853/(12141853+36914043) = 24.75% (very bad)
```

+ Big Keys
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 –bigkeys
# If the keys is too big, consume too much space, may need to redesign about it.
```

+ Show All the keys
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 --scan --pattern '*'
# we can see all the keys detail
```

+ Check Key TTL(expire time)
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> TTL mykey
# If the key has the TTL set, will remove from the Redis cache when time up. Could cause the missing ache when search
10.10.10.10:6389> info
# Find
# expired_keys:6856
# means we have 6856 keys has expired since Redis start
```

+ Slow Log
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> SLOWLOG GET 10
# Get 10 slow cache access, for example:
# 1) (integer) 381  # Unique ID
# 2) (integer) 1493366877 # Unix timestamp, convert to human time is about 07:50:19:285
# 3) (integer) 38021 # Execution time in microseconds, is 0.038021 seconds
# 4) 1) "DEL"
#    2) "Dashboard-SearchResultsData:\xac\xed\x00\x05sr\x003com.equilar.international.model.dashboard.P4PSearch':
#       \x96Ro\xa6\x10\x1b\x02\x00\x1eL\x00\nbeginIndext\x00\x13Ljava/lang/Int... (2056 more bytes)"
# In this case, use 0.038021 seconds, it is bad when response time > 10 ms
```

+ Evicted Key
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> info
# Find
# evicted_keys:27764495
# means we have 27764495 keys evicted due to the cache hit the memory limit, replace by Redis algorithm(LRU)
# Find
# used_memory_peak:4307511872
# used_memory_peak_human:4.01G
# we use max 4.01G memory, that's the our Redis total memory, need to increase the psychical memory for Redis.
```

Redis Memory Check
-------------------------
+ Evicted Key
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> info
# Find
# used_memory:3538196240 -> used memory in bytes
# used_memory_human:3.30G -> same as used_memory
# used_memory_rss:3792228352 -> actually memory used in bytes
# used_memory_peak:4307511872 -> max memory usage in bytes, if redis use more memory than it's config, will start to swap the physical memory, which will cause performance go down
# used_memory_peak_human:4.01G -> same as used_memory_peek
# mem_fragmentation_ratio:1.07 -> = used_memory_rss/used_memory,
# >1.5 means too much fragment memory, Redis waste too much memory,
# <1.0 means some cache missing, which should not happened
```

Redis Client Connection Check
-------------------------

+ Client List
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> client list
# For Example:
# id=231876 addr=10.1.28.134:49916 fd=21 name= age=428055 idle=428034 flags=N db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=0 obl=0 oll=0 omem=0 events=r cmd=get
# id: unique client id, increase by 1 when has new connect. Reset to 1 when Redis reboot
# addr: client ip
# fd: description mark for socket, same as the FD in lsof
# name: client name
# age: client live time (seconds)
# idle: client idle time (seconds)
# flages: client type, has 13 in total. Common type: N(normal client), M(master), S(Slave), O(monitor)
# db: the database series number client use
# sub/psub: subscription channel/mode
# multi: how mand commands has run in current transaction
# qbuf: query buffer bytes (important)
# qbuf-free: query buffer free bytes (important)
# omem: changeable output buffer memory bytes (important)
# events: event file description (r/w)
# cmd: last command client run, not include parameter
# 
# client connection will consume the Redis memory, so make sure qbuf + qbuf-free and omem are in the reasonable range
```

+ Client List
```shell
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389
10.10.10.10:6389> info
# Find
# blocked_clients = 0
# If any client was blocked(BLPOP, BRPOP, BRPOPLPUSH), that's not right
```

Monitor Tools
-------------------------
All three are open source project, those Monitor tools are based on the redis info.

1) REDIS-STAT: [redis-stat](https://github.com/junegunn/redis-stat)

2) RedisLive: [RedisLive](https://github.com/nkrode/RedisLive)

3) Opserver: [opserver](https://github.com/opserver/Opserver)

Reference
-------------------------
https://zhuoroger.github.io/2016/08/14/redis-data-loss/
https://zhuoroger.github.io/2016/08/20/redis-monitor-and-alarm/
https://blog.yowko.com/2017/03/redis-monitoring.html
