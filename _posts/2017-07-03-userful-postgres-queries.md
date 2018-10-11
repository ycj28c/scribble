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
```shell
select * from pg_foreign_server;
select * from pg_user_mappings;
alter server aserver options (set host 'a.com', set dbname 'a_server');
alter user mapping for bserver server aserver options (set user 'usera', set password 'xxx');
```

*  rollback changes
```shell
begin;
-- your query
rollback;
```

