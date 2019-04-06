---
layout: post
title: Query Optimize Postgres
disqus: y
share: y
categories: [Database]
tags: [Postgres, Performance]
---

Optimize
----------

As we all knows, there are some general ways to optimize the query:

*1.Add index*

In Postgres it support multiple index, such as like index which will be different from equal index, also it provide some new feature such as array index.
~~~
DROP INDEX if exists ralph_idx1;
CREATE INDEX if not exists ralph_idx1 ON raw_data_ralph (id);
~~~

There are some magic index, for example:
~~~
--before
LEFT JOIN document d ON cast(d.document_id AS TEXT) = substr(mmd.bio, 0, position(',' IN mmd.bio))
~~~

~~~
--after
LEFT JOIN document d ON d.document_id = coalesce(substr(mmd.bio, 0, position(',' IN mmd.bio)), null)::bigint
~~~
Index only take effect on the left side, actually, there is d.document_id index already in the document table, however, the join query try to compare the case TEXT value with the substr, which TEXT type. After change, the index works as expect, the query will be 100 times faster.

*2.Change the order*

Such as A join B Join C will be different from C join B join A.

*3.Change the data range*

Let's assume A has 1000000 data, B has 1000000 data, C has 10000000 data. We want find all A join B join C where the A has price <100.

In this case, we can generate small A set on the fly.
~~~sql
WITH low_price as (
    select * from A where price < 100
),
~~~

*4.Use CLUSTER*
May works for some situation such as data split by year.
~~~
CLUSTER raw_data_ralph USING ralph_idx1;
ANALYZE raw_data_ralph;
~~~

*5.vacuum table*
This may happened when the table is updated many many times per day. In this case, the old data not removed from the data file, still occupy the space, the Postgres optimizer may not correctly collect the table information. Need vaccum.
~~~
vacuum raw_data_ralph;
~~~ 

Now, here is a new way I just know, use temp table.

*4.Use temp table*

When we do the '3. Change the data range', Postgres will generate some temp table such as low_price table on the fly, however, those table don't have the index, if those temp table are also big, it lower the performance. So here play the trick, for each transaction, we build the TEMPORARY TABLE, create index for it, after everything done, remove the TEMPORARY TABLE. (The TEMPORARY TABLE will remove when transaction is done, however if other query runs in the same transaction may cause the conflict). In the meanwhile, can use Postgres function to make whole transaction more clear. Simple example below:

~~~sql
DROP FUNCTION IF EXISTS calPrice( BIGINT [] );
CREATE OR REPLACE FUNCTION calPrice(p_variable BIGINT[]){
	RETURNS TABLE(item_id           BIGINT, 
				  price             BIGINT
  ) AS $$
BEGIN
  DROP TABLE IF EXISTS A_tmp;	
  CREATE TEMPORARY TABLE A_tmp AS select * from A where price < 100;
  CREATE INDEX A_tmp_idx ON A_tmp (item_id);
  
  RETURN QUERY 
  
  WITH low_price_ab AS (
     select * from B b join A_tmp a_tmp on b.rfe_id = a_tmp.rfe_id
  ), low_price_ac AS (
	select * from C c join A_tmp a_tmp on c.rfe_id = a_tmp.rfe_id
  )
  
  select 
  pt.item_id,
  pt.price
  from product pt
  join low_price_ab ab on pt.rfe_id = ab.rfe_id
  join low_price_ac ac on pt.rfe_id = ac.rfe_id
  where ab.onsale = 'Y' and ac.onsale = 'N';
  
  DROP TABLE A_tmp;
  
  RETURN;
END;
$$
LANGUAGE plpgsql
VOLATILE;
  
}

SELECT * FROM calPrice(ARRAY [:item_ids]);
~~~

Common Query Optimize tips (Chinese version)
--------------------------
>1.对查询进行优化，应尽量避免全表扫描，首先应考虑在 where 及 order by 涉及的列上建立索引。
>2.应尽量避免在 where 子句中对字段进行 null 值判断，否则将导致引擎放弃使用索引而进行全表扫描，如： select id from t where num is null 可以在num上设置默认值0，确保表中num列没有null值，然后这样查询： select id from t where num=0
>3.应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描
>4.应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如： select id from t where num=10 or num=20 可以这样查询： select id from t where num=10 union all select id from t where num=20
>5.in 和 not in 也要慎用，否则会导致全表扫描，如： select id from t where num in(1,2,3) 对于连续的数值，能用 between 就不要用 in 了： select id from t where num between 1 and 3
>6.如果在 where 子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。如下面语句将进行全表扫描： select id from t where num=@num 可以改为强制查询使用索引： select id from t with(index(索引名)) where num=@num
>7.应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where num/2=100 应改为: select id from t where num=100*2
>8.应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where substring(name,1,3)='abc'--name以abc开头的id select id from t where datediff(day,createdate,'2005-11-30')=0--‘2005-11-30’生成的id 应改为: select id from t where name like 'abc%' select id from t where createdate>='2005-11-30' and createdate<'2005-12-1'
>9.不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。

Tips
----------
To get the cost of query
~~~sql
-- estimate cost, query not run
EXPLAIN select name from user;
-- run the actual query
EXPLAIN analyze select name from user;
~~~

Reference
----------
[Chapter 14. Performance Tips](https://www.postgresql.org/docs/9.6/using-explain.html)
[SQL语句优化的41条建议](https://juejin.im/post/5aa7703c6fb9a028c8128739)
[30条SQL查询优化原则](developer.51cto.com/art/201102/245903.htm)
