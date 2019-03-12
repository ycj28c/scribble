---
layout: post
title: Postgres Log Analyze Pgbadger and performance issue troubleshot
disqus: y
share: y
categories: [Database, Analytics]
tags: [Postgres, Log, Pgbadger]
---

Issue
-----
We have some ETL scripts running during the night time, from one database to another database, usually it took 30m to complete all, but recently like today took almost 4 hours. 

Troubleshot
-----------

Here is my thought:
* ETL server in high pressure -> but no
* Jenkins server is slow -> but others are fast, so no
* Database has lock, or in high loader
* External slowness, such as filing copy slow -> but no
* Part of scripts are slow -> but no, it is overall slow

Identify the hardware, the network, cpu, memory, io looks fine. Check all the scripts logs, they were running as usual, no suspect process found. Just everything were slow. Suspect the slowness happened at database side.

We are using postgres database, unlike oracle, it don't have too much tools embody, hard to find third party tools as well. We didn't have any monitor for postgres, the only thing can do here is to analyze the log.

There are only two tools support postgres log analyze I can found, pgfouine and pgbadger, they are script tools, but still painful install on windows(I choose pgbadger).

Some useful tips:
* Install cygwin or gitbash in windows
* Install the latest version of pgbadger
~~~
$ perl -version
~~~

* Make sure you system environment point to right place
* To support csv log analyze, must install plugin
~~~
$ cd pgbadger-9.2
$ cpan Text::CSV
~~~

* download the pg log
assume the pg_log is called pglog03162018.csv

* Run pgbadger in windows
~~~
$ ./pgbadger pglog03162018.csv
~~~

Then it generated very beautiful html report, from the slowest query and lock page, helped we find the bottleneck.

Update at 2019/03/12
--------------------
Follow below step to troubleshot the slow target  
1. Check the system load (cpu load) [系统负载讲解](http://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html)  
1 cpu can only handle 1.0 load, 2 cpu can handle max 2.0 etc. If the load is continually high, it is guarantee to be slow.  
~~~bash
-- check how many cpu you have 
grep -c 'model name' /proc/cpuinfo
~~~  
Check other hardware performance as well, make sure memory, io and network is not the bottleneck.  

2. If load is too high, need to identify which cause it. Use the pgbadger is good way, but it require pg_log, sometimes the normal user don't have permission. below are other ways:  
1) use pg_stat_statmenet plugin
~~~sql
create extension pg_stat_statements;
select pg_stat_reset();
select pg_stat_statements_reset();
--wait the plugin collect information, then run
select * from pg_stat_statements order by total_time desc limit 5;
~~~
2) check the longest activity person  
~~~sql
select datname, usename, client_addr, application_name, state, backend_start, xact_start, xact_stay, query_start, query_stay, replace(query, chr(10), ' ') as query from (select pgsa.datname as datname, pgsa.usename as usename, pgsa.client_addr client_addr, pgsa.application_name as application_name, pgsa.state as state, pgsa.backend_start as backend_start, pgsa.xact_start as xact_start, extract(epoch from (now() - pgsa.xact_start)) as xact_stay, pgsa.query_start as query_start, extract(epoch from (now() - pgsa.query_start)) as query_stay , pgsa.query as query from pg_stat_activity as pgsa where pgsa.state != 'idle' and pgsa.state != 'idle in transaction' and pgsa.state != 'idle in transaction (aborted)') idleconnections order by query_stay desc limit 5;
~~~
3) check the table scan information, handle the big whole table scan case
~~~
-- find the most whole seq scan table
select * from pg_stat_user_tables where n_live_tup > 100000 and seq_scan > 0 order by seq_tup_read desc limit 10;
-- find the query is running for that table
select * from pg_stat_activity where query ilike '%<table name>%' and query_start - now() > interval '10 seconds';
-- can also use pg_stat_statements do the same thing
select * from pg_stat_statements where query ilike '%<table>%'order by shared_blks_hit+shared_blks_read desc limit 3;
~~~
4) cancel or kill the most effect query, recover business
~~~
select pg_cancel_backend(pid) from pg_stat_activity where  query like '%<query text>%' and pid != pg_backend_pid();
select pg_terminate_backend(pid) from pg_stat_activity where  query like '%<query text>%' and pid != pg_backend_pid();
~~~
5) optimize the queries  
a. Use *ANALYZEE<table>* or *VACUUM ANZLYZE<table>* to update the table statistic. Try to avoid run it in peer time.  
b. Execute explain(query text) or explain (buffers true, analyze true, verbose true) (query text) command to identify the query execution plan.  
c. Optimize the queries, remove useless join, modify *UNION ALL*, use *JOIN CLAUSE* to stable the order etc.

for more query optimize, check this [QUERY OPTIMIZE POSTGRES](https://ycj28c.github.io/database/2019/01/29/query-optimize-postgres/)

Reference
---------
[A fast PostgreSQL Log Analyzer](https://github.com/dalibo/pgbadger)

[ActivePerl](https://www.activestate.com/activeperl)

[PostgreSQL CPU占用100%性能分析及慢sql优化](https://www.centos.bz/2017/08/postgresql-cpu-100-slow-sql)

[系统负载讲解](http://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html)