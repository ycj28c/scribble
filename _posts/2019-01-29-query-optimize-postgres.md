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
