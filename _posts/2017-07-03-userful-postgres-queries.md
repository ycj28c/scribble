---
layout: post
title: Useful Postgres Queries
disqus: y
share: y
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
