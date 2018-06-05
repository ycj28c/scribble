---
layout: post
title: Serialize Transaction Issue
disqus: y
share: y
categories: [Database]
tags: [Postgres, SpringBatch]
---

Issue
-----
We have new jobs run by Spring Batch, at beginning it was fine, but two days later, we aware the below issue in the log.
~~~
Caused by: org.postgresql.util.PSQLException: ERROR: could not serialize access due to read/write dependencies among transact
ions
  Detail: Reason code: Canceled on identification as a pivot, during commit attempt.
  Hint: The transaction might succeed if retried.
        at org.postgresql.core.v3.QueryExecutorImpl.receiveErrorResponse(QueryExecutorImpl.java:2455) ~[postgresql-9.4.1212.j
re7.jar!/:9.4.1212.jre7]
        at org.postgresql.core.v3.QueryExecutorImpl.processResults(QueryExecutorImpl.java:2155) ~[postgresql-9.4.1212.jre7.ja
r!/:9.4.1212.jre7]
        at org.postgresql.core.v3.QueryExecutorImpl.execute(QueryExecutorImpl.java:288) ~[postgresql-9.4.1212.jre7.jar!/:9.4.
1212.jre7]
        at org.postgresql.jdbc.PgConnection.executeTransactionCommand(PgConnection.java:776) ~[postgresql-9.4.1212.jre7.jar!/
:9.4.1212.jre7]
        at org.postgresql.jdbc.PgConnection.commit(PgConnection.java:797) ~[postgresql-9.4.1212.jre7.jar!/:9.4.1212.jre7]
        at org.apache.commons.dbcp.DelegatingConnection.commit(DelegatingConnection.java:334) ~[commons-dbcp-1.4.jar!/:1.4]
        at org.apache.commons.dbcp.PoolingDataSource$PoolGuardConnectionWrapper.commit(PoolingDataSource.java:211) ~[commons-
dbcp-1.4.jar!/:1.4]
~~~

Troubleshot
-----------
After research, it is because we have two batch jobs run at same time, both will run query at same time which causing the conflict. By default the Spring Batch is using the SERIALIZED transaction, this is mainly used for single job and data sensitive scenarios. However, when we ran multiple tasks in the mean time, it will cause exception. (It assume we use the retry mechanism in our code)

By adding the below configuration in Spring Batch, the issue resolved:
~~~
<bean id="jobRepository" class="XXXXXXXXXX">
	<property name="dataSource" ref="dataSource" />
	<property name="isolationLevelForCreate" value="ISOLATION_READ_UNCOMMITTED"/>
</bean>
~~~

Spring Batch official guide: 
>If the namespace is used, transactional advice will be automatically created around the repository. This is to ensure that the batch meta data, including state that is necessary for restarts after a failure, is persisted correctly. The behavior of the framework is not well defined if the repository methods are not transactional. The isolation level in the create* method attributes is specified separately to ensure that when jobs are launched, if two processes are trying to launch the same job at the same time, only one will succeed. The default isolation level for that method is SERIALIZABLE, which is quite aggressive: READ_COMMITTED would work just as well; READ_UNCOMMITTED would be fine if two processes are not likely to collide in this way. However, since a call to the create* method is quite short, it is unlikely that the SERIALIZED will cause problems, as long as the database platform supports it. However, this can be overridden.

Spring Transaction Level
------------------------
In the reference, has very good material describe the Spring database transaction difference, the major information shows in below table.

|Isolation Level|Dirty Read|Nonrepeatable Read|Phantom Read|
|:---------------:|:----------:|:------------------:|:------------:|
|Read uncommitted|Possible|Possible|Possible|
|Read committed|Not possible|Possible|Possible|
|Repeatable read|Not possible|Not possible|Possible|
|Serializable|Not possible|Not possible|Not possible|

Reference
---------
[Spring transaction isolation level tutorial](http://www.byteslounge.com/tutorials/spring-transaction-isolation-tutorial)

[4. Configuring and Running a Job](https://docs.spring.io/spring-batch/trunk/reference/html/configureJob.html#txConfigForJobRepository)

[13.2. Transaction Isolation](https://www.postgresql.org/docs/9.1/static/transaction-iso.html)

[Spring Batch ORA-08177: can't serialize access for this transaction when running single job, SERIALIZED isolation level](https://stackoverflow.com/questions/22364432/spring-batch-ora-08177-cant-serialize-access-for-this-transaction-when-running)