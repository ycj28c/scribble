---
layout: post
title: Postgres Maintenance And Urgent Case
disqus: y
share: y
categories: [Database, Analytics]
tags: [Postgres, Maintenance]
---

BackGround
-----------
Previous, we did some research for Postgres, check below:  
1.[Useful Postgres Queries](https://ycj28c.github.io/database/2017/07/03/userful-postgres-queries/)  
2.[Postgres Log Analyze Pgbadger](https://ycj28c.github.io/database/analytics/2018/04/10/postgres-log-analyze-pgbadger/)  
3.[Query Optimize Postgres](https://ycj28c.github.io/database/2019/01/29/query-optimize-postgres/)  
Now we also need to do maintenance and keep the database robust.

How To Maintenance
--------------------
Follow below step to troubleshot the slow target  
1. Check the system load (cpu load) [系统负载讲解](http://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html)  
1 cpu can only handle 1.0 load, 2 cpu can handle max 2.0 etc. If the load is continually high, it is guarantee to be slow.  
~~~bash
-- check how many cpu you have 
grep -c 'model name' /proc/cpuinfo
-- other metrics
top
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

SELECT rolname,
    calls,
    total_time,
    mean_time,
    max_time,
    stddev_time,
    rows,
    regexp_replace(query, '[ \t\n]+', ' ', 'g') AS query_text
FROM pg_stat_statements
JOIN pg_roles r ON r.oid = userid
WHERE calls > 100
AND rolname NOT LIKE '%backup'
ORDER BY mean_time DESC
LIMIT 15;
~~~
2) check lock
~~~
--for example, you know the 'market_index' table is frozen
select * from pg_locks where granted and relation = 'market_index'::regclass;

select * from pg_stat_activity where pid in (select distinct(pid) from pg_locks);

select * from pg_stat_activity where pid = '28769';
~~~
3) check the longest activity person  
~~~sql
SELECT
  datname,
  usename,
  client_addr,
  application_name,
  state,
  backend_start,
  xact_start,
  xact_stay,
  query_start,
  query_stay,
  replace(query, chr(10), ' ') AS query
FROM (SELECT
        pgsa.datname                                   AS datname,
        pgsa.usename                                   AS usename,
        pgsa.client_addr                                  client_addr,
        pgsa.application_name                          AS application_name,
        pgsa.state                                     AS state,
        pgsa.backend_start                             AS backend_start,
        pgsa.xact_start                                AS xact_start,
        extract(EPOCH FROM (now() - pgsa.xact_start))  AS xact_stay,
        pgsa.query_start                               AS query_start,
        extract(EPOCH FROM (now() - pgsa.query_start)) AS query_stay,
        pgsa.query                                     AS query
      FROM pg_stat_activity AS pgsa
      WHERE pgsa.state != 'idle' AND pgsa.state != 'idle in transaction' AND
            pgsa.state != 'idle in transaction (aborted)') idleconnections
ORDER BY query_stay DESC
LIMIT 5;
~~~
4) check the table scan information, handle the big whole table scan case
~~~
-- find the most whole seq scan table
select * from pg_stat_user_tables where n_live_tup > 100000 and seq_scan > 0 order by seq_tup_read desc limit 10;
-- find the query is running for that table
select * from pg_stat_activity where query ilike '%<table name>%' and query_start - now() > interval '10 seconds';
-- can also use pg_stat_statements do the same thing
select * from pg_stat_statements where query ilike '%<table>%'order by shared_blks_hit+shared_blks_read desc limit 3;
~~~
5) cancel or kill the most effect query, recover business
~~~
select pg_cancel_backend(pid) from pg_stat_activity where  query like '%<query text>%' and pid != pg_backend_pid();
select pg_terminate_backend(pid) from pg_stat_activity where  query like '%<query text>%' and pid != pg_backend_pid();
~~~
This is the action item, kill the query blocking.  
6) optimize the queries  
a. Use *ANALYZEE<table>* or *VACUUM ANZLYZE<table>* to update the table statistic. Try to avoid run it in peer time.  
b. Execute explain(query text) or explain (buffers true, analyze true, verbose true) (query text) command to identify the query execution plan.  
c. Optimize the queries, remove useless join, modify *UNION ALL*, use *JOIN CLAUSE* to stable the order etc.

for more query optimize, check this [QUERY OPTIMIZE POSTGRES](https://ycj28c.github.io/database/2019/01/29/query-optimize-postgres/)

Reference
---------
[PostgreSQL CPU占用100%性能分析及慢sql优化](https://www.centos.bz/2017/08/postgresql-cpu-100-slow-sql)

[系统负载讲解](http://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html)

[饿了么 PostgreSQL 优化之旅](https://www.cnblogs.com/zhangeamon/p/8269295.html)