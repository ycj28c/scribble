---
layout: post
title: Useful Postgres Queries
disqus: y
share: y
categories: [Database]
tags: [Postgres]
---

* convert table to json

```sql
select to_json(pc) from proxy_company pc;
```

* converting a whole row to json; one row for each json

```sql
SELECT
  pc.company_id,
  row_to_json(pc)
FROM proxy_company pc;
```

* aggregate the result and to json; building {company_id: [{row}, {row}]}

```sql
SELECT
  t.company_id,
  row_to_json(t)
FROM (
       SELECT
         pc.company_id,
         json_agg(row_to_json(pc)) fiscal_years
       FROM proxy_company pc
       GROUP BY company_id
     ) t order by company_id;
```

* check current user connection

```sql
SELECT * FROM pg_stat_activity where state = 'active';
```

* check max connection setting

```sql
show max_connections;
```

* find the lock the pid and kill it

```sql
--for example, you know the 'market_index' table is frozen
select * from pg_locks where granted and relation = 'market_index'::regclass;

select * from pg_stat_activity where pid in (select distinct(pid) from pg_locks);

select * from pg_stat_activity where pid = '28769';

select pg_terminate_backend(28769);
```

*  pg_dump the mview and its index

```shell
pg_dump -sOx -t cdna_search -h 10.1.50.35 -U insight insight_qa > cdna_search.sql
```

*  postgres foreign link related

```sql
select * from pg_foreign_server;
select * from pg_user_mappings;
alter server aserver options (set host 'a.com', set dbname 'a_server');
alter user mapping for bserver server aserver options (set user 'usera', set password 'xxx');
```

*  rollback changes

```sql
begin;
-- your query
rollback;
```

*  recursive query
[Find Parent Recursively using Query](https://stackoverflow.com/questions/3699395/find-parent-recursively-using-query)
```sql
WITH RECURSIVE tree(child, root) AS (
   select c.executive_id, c.merged_to_executive_id from executive c join executive p on c.merged_to_executive_id = p.executive_id WHERE p.merged_to_executive_id IS NULL
   UNION
   select executive_id, root from tree
   inner join executive on tree.child = executive.merged_to_executive_id
)
SELECT * FROM tree where child = 135477;
```

*  compare two query data
```
create temporary table tmp1 as select * for user where id = 1;
create temporary table tmp2 as select * for user where id = 2;

-- is data missing in tmp1
select * from tmp1
except
select * from tmp2;

-- is data missing in tmp2
select * from tmp2
except
select * from tmp1;
```
