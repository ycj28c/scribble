---
layout: post
title: Redis Bgsave Troubleshoot
disqus: y
share: y
---

Issue Introduce
-------------------------
We encouter a issue that redis server suddenly went slow, found it is relate to bgsave, this article is about how troubleshoot and solve it. 

Issue Trouble
-------------------------
Increased the redis memory to 15G about 1 month ago, every 3 week will do a flushall and warmup cache (warmup cache means manually insert lots of redis key value by spring cache). Yesterday suddenly the redis is getting slow, a lot of connection exception. 

The redis latency is very bad, maximum lik 7000, avg 25
```bash
/usr/local/bin/redis-cli -h localhost -p 6389 --latency
```

Check the redis server, find there are two redis server running, each take half of the physical memory 8G and virtual memory 24G.
```bash
top
```

check the pid of redis, the one runs at Jul04 called redis-rdb-bgsave
```bash
ps -ef|grep redis
```

After research, the bgsave is "Save the DB in background. The OK code is immediately returned. Redis forks, the parent continues to serve the clients, the child saves the DB on disk then exits. A client may be able to check if the operation succeeded using the LASTSAVE command."

Issue Reason
-------------------------
Because we use large redis memory for product(15G), but not too much server memory(total 19G?), the redis snapshot bgsave don't have lot of resource to run, it will took long time to dump data into disk.
Check the dump file(which define in redis.conf, default in /var/lib/redis)
```
-rw-r--r--. 1 redis redis 8846152329 Jul  4 20:49 dump-redis-product.rdb
-rw-r--r--. 1 redis redis  210476057 Jul  5 12:08 redis-product.log
-rw-r--r--. 1 redis redis 6252507136 Jul  5 12:08 temp-1995.rdb
```
we can see now dumped 6252507136, it need time to reach to dump size 8846152329 last time.

The bgsave is mainly for redis restart recover, since our product flushall the redis cache, warm and clean cache everytime, we don't quite relay on the redis persistent mechanism, we can disable this feature by change the redis.conf.

Solution
-------------------------
1. add more physical memory for server(unfortunally we can't)
2. change the properties, disable the bgsave feature
default redis configuration directory: /etc/redis/redis-insight.conf
```json
# comment below setting, disable the bgsave feature
    save 900 1
    save 300 10
    save 60 10000
# set this to no, means when error occurs, don't persistant, redis can still work
	stop-writes-on-bgsave-error no
```

There also other redis persistant machanism AOF, didn't research on that yet.  

Reference
-------------------------
[https://www.zhihu.com/question/53616538/answer/145017374](https://www.zhihu.com/question/53616538/answer/145017374)
[http://redisdoc.com/topic/persistence.html](http://redisdoc.com/topic/persistence.html)
