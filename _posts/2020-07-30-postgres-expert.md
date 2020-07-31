---
layout: post
title: Postgres Expert Report
disqus: y
share: y
categories: [Database]
tags: [Postgres, Performance]
---

Background
----------
分享一个Postgres的专家分析报告，以及想法

Summary of Conclusions 
--------
We recommend the following:  
* Increase the number of execution units available to the PostgreSQL server.  
* Increase memory, I/O subsystem capacity, or both.  
* If the connection bursts as observed in the analysis are routine, consider implementing a pooler such as pgbouncer.  
* Use session-local work_mem settings on materialized view refresh operations and other high-memory-usage queries, if only one or a small number are running in parallel.  
* Certain postgresql.conf and sysctl.conf changes, summarized at the end.  

结论： 总结几个要解决的问题，加CPU，加Memory，加IO capacity，考虑加pgbouncer优化连接池，为大mview设置单独的work_mem，优化配置文件。

Data Collection Notes  
--------
During the data collection period, there were two distinct patterns of database usage:  
* During the “normal” period, there was a mix of UPDATE and SELECT queries performed on the database.  
* During what we will call for this report the “refresh” period, there was a large volume of INSERTs, although the UPDATE and SELECT traffic continued.  
The behavior of the system was notably different in these two periods.
  
结论： 这一部分针对每日运行情况，总结出正常和高压两种应用场景，以及两种情况的系统负载。 

CPU Usage: 
--------   
During the “normal” period, the database did not overtax the CPU capacity of the system. While  there a few small bursts to 100% use of a single execution unit (“core”) at a time, CPU was not the limiting factor.  
During the “refresh” period, CPU usage on all eight execution units reached and was sustained at  100% (or nearly so). CPU was definitely the limiting factor during this period, and it is likely that  more and faster execution units will increase system throughput. 

结论： 显然在高压情况下CPU基本上一直是100%，显然是瓶颈。

RAM Usage: 
--------   
During both the “normal” and “refresh” period, RAM usage stayed within what we consider acceptable limits for a PostgreSQL server. The total of free memory plus the OS file system cache stayed at 80% for the “normal” period, and only slightly below that for the “refresh” period (probably due to working memory use).  
We did not observe large file-system flush operations or other anomalies. We do recommend sysctl.conf settings of:
```
vm.overcommit_memory = 2  
vm.overcommit_ratio = 100  
vm.dirty_background_ratio = 5  
vm.dirty_ratio = 80  
vm.swappiness = 1  
```
This will generally keep the Linux Out-of-Memory Killer process from unnecessarily killing PostgreSQL processes, and will prevent throughput bottlenecks due to file system buffer flushing.  See the next section for recommendations on RAM.  
We also recommend the following postgresql.conf setting:  
```
effective_cache_size = 28GB  
```
This is a planner setting, rather than an allocation request, and more closely corresponds to the actual amount of cache (file system cache plus shared buffers) available on your system.  

结论： 内存不存在严重问题，不过通过修改一些设置，可以优化内存使用效率。

I/O Subsystem  
--------
During most of the analysis period, both “normal” and “refresh”, the I/O subsystem hosting the data volume reached maximum capacity. Both the service wait time (the amount of time an individual I/O request waited to be handled) and the queue length (the number of I/O requests waiting to be handled) increased by enough to show that the I/O subsystem was a limiting factor.  The primary I/O operations were read operations, which indicates that more RAM might be helpful to provide more caching and reduce the number of I/O operations that need to be performed to fulfill queries. Of course, increasing the available bandwidth and reducing the  
latency of the I/O subsystem will help in this case as well.   

IO也是个问题，有很高的等待时间。但是disk的读取速度是固定的，增快速度往往需要增加内存。不过主要问题不是速度，而是throughput，提高系统的带库才是提高系统性能主要考虑。

Connection Activity  
---------
In general, the number of connections to the database were modest, and the connection rate (the  number of connections opened per minute) was low. There was, however, one very large burst we observed of new connections opening and closing. This can cause significant load on the server, as each new connection opening requires that an OS process be forked to handle it. If this  pattern is expected, it would be worth investigating a pooler (such as pgbouncer) to reduce the connection open rate on the server; if it’s not expected, it should be diagnosed and remediated.  

结论： 数据库的连接池应该保持尽可能小，因为每个新连接都需要OS的系统资源，在连接数频繁的增加和减少情况下尤其影响性能。不过我们明显木有办法，因为要连接的东西太多，限制500个连接，实际都要有1000+的连接，只能动态连接池，用完就删除。这里推荐了pgbouncer维护连接池优化性能，不过估计意义不大。

Checkpointing  
---------
At periodic intervals, PostgreSQL flushes all dirty buffers that it maintains in its private shared buffers space to disk. This is a very high I/O operation, and needs to be properly tuned to avoid swamping the I/O subsystem.  
We did notice some very high I/O points in the checkpoint process, which corresponded (unsurprisingly) with the “refresh” portion of the update. We generally recommend the following  settings in order to smooth out the checkpoint process:  
```
checkpoint_timeout = 15min  
max_wal_size = 4GB  
```
We also recommend checkpoint_completion_target = 0.9, which you already have set.  
While not strictly part of the checkpointing process, we recommend: 
```
min_wal_size = 1GB  
```
This reduces the number of WAL segment files that PostgreSQL needs to create, which can speed up the WAL writing process. The only cost is increased disk usage. 

结论： checkpoint就是大量记录日志，会造成显著的io影响，需要根据系统使用情况设定checkpoint的大小和周期。不过我们的更新量比较小，所以日志并不大，性能影响很小。

Temporary Files
----------  
PostgreSQL creates temporary files to handle certain operations (sorts, joins, etc.) when the query planner estimates that the amount of memory required by the operation will exceed that allowed by the work_mem setting.  
We observed quite a few temporary files being created during the analysis run. Some of them were close to the current work_mem setting of 104MB; many were significantly over that. Many materialized view refreshes required work_mem in the 2-3GB range. Of course, doing those operations on disk will be significantly slower than doing them in memory, and that is certainly a  contributing factor to the I/O saturation. It’s unwise to increase work_mem globally in this case, as multiple processes running in parallel could easily exhaust physical memory. However, work_mem can be set locally for a particular session, such as the materialized view refreshes; since only one process can (by definition) be doing a REFRESH MATERIALIZED VIEW CONCURRENTLY operation for a particular view, the memory usage is limited.  

One particular query created a 9GB temporary file (see below in “Queries” for the query text). If  this query is run by itself and not with multiple copies in parallel, it would make sense to allow it a local work_mem setting large enough to allow it to operate in memory. We only observed one instance of that query running. Locking We did not observe any lock contention issues in the database; only one statement was delayed by a lock, which was COMMIT.  

结论： 临时文件会在一些query的操作比较sort和join中使用，我们有很多大mview，部分的work_mem使用量达到好几个G，当然不能改global的work_mem设置，不过Postgres支持对每个session设置work_mem，所以我们可以针对大mview自定义local的work_mem，这一点很好。

Indexes  
---------
We did observe a number of tables with a large number of sequential scans (see report in the .zip  archive). These tables are often candidates for new indexes, depending on the queries being run on them. We did not find any unused or duplicate indexes. 

结论： index嘛大家都懂，可以通过查看postgres的index分析表找出可能的全表搜索，针对query增加需要的index。

Bloat 
----------
PostgreSQL tables and indexes can, because of the Multi-Version Concurrency Control model, become bloated. “Bloat” is space in the table or index that is allocated on disk, but is not being used by live data. Some bloat is always present in the database, and we did not find any excessively bloated tales or indexes. This is a good sign that autovacuum is correctly configured and is keeping up with database activity.  

结论： 表膨胀问题，postgres需要周期性的跑autovacuum，让表啊index啊等等的信息保持更新，大量的字段insert和update会让某些表变得臃肿无比，需要好的autovacuum设置避免这种情况。

Queries  
----------
The slowest-performing queries in the database were largely, and we are sure unsurprisingly, the materialized view refresh operations. Since these are often on very large views and have foreign tables, how much optimization can be done may be limited.

结论： 这个也很明显，Pgbadger可以帮助找出慢query，内置的pg_stat_statements也能帮助找慢query

Other Recommendations  
-----------
PostgreSQL maintains a temporary statistics file that it uses to track a variety of system statistics,  such as tuple modifications, vacuum operations, etc. During normal system operations, this file is  very heavily written to, and it copied to permanent storage during system shutdown. We recommend that the statistics temporary file to a RAM disk to speed up these operations and remove I/O load from the data volume. A very small RAM disk (16MB) can be used. The parameter that controls the location of this file is stats_temp_directory. Right now, there is no streaming replica attached to the server, although you are doing WAL archiving. We always recommend a streaming replica for fast failover in case the primary database server fails; restoring from a backup can be very time consuming. 

结论： 这里推荐的在postgres宕机时候通过一个Ram disk保存stats_temp_directory信息来加快恢复速度。

Conclusions  
----------
The system is overtaxed on both CPU and I/O. Adding more RAM might help the I/O limitations, although it will simply transfer more of the work to the CPU, so ultimately, a system  with higher capacity will be required to expand throughput. We recommend the postgresql.conf changes listed below; some are mentioned above, and some we consider generally beneficial to any PostgreSQL system. 
We also recommend the sysctl.conf changes listed below. These are appropriate on any Linux  system running as a PostgreSQL server. We will be happy to analyze the materialized view refresh queries in order to provide suggestions  as to their performance; this will require coordination so that we do not impact normal system operations with our testing. 
 
postgresql.conf recommendations  
```
effective_cache_size = 28GB  
checkpoint_timeout = 15min  
min_wal_size = 1GB  
max_wal_size = 4GB  
wal_log_hints = on  
wal_compression = on  
random_page_cost = 2.0  
track_commit_timestamp = on  
track_io_timing = on  
track_functions = 'all'
```  
sysctl.conf settings
```  
vm.overcommit_memory = 2  
vm.overcommit_ratio = 100  
vm.dirty_background_ratio = 5  
vm.dirty_ratio = 80   
```

结论： 总结了一下可以做的优化方向。

