---
layout: post
title: Postgres Log Analyze Pgbadger 
disqus: y
share: y
categories: [Database, Analytics]
tags: [Postgres, Log]
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
$ cpan Text::CSV
~~~
* Run pgbadger in windows
~~~
$ ./pgbadger pglog03162018.csv
~~~

Then it generated very beautiful html report, from the slowest query and lock page, helped we find the bottleneck.

Reference
---------
[A fast PostgreSQL Log Analyzer](https://github.com/dalibo/pgbadger)

[ActivePerl](https://www.activestate.com/activeperl)