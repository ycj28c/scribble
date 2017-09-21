---
layout: post
title: Research On Sumologic
disqus: y
share: y
categories: [Analytics]
---

Purpose
---------------------
最近部門安裝了sumologic，用於日志的管理和監控，嘗試了一下sumologic，此文是對sumologic的理解。最近幾年監控系統非常流行，New Relic啊，App Dynamic啊，Spluck啊等等，前幾天看Spluck的待遇還是業界最高的。sumologic就坐落在Redwood City，一大座建築就做這一個產品，讓我們看看這是啥吧。

How It Works
---------------------
關於具體如何安裝，官方已經有詳細的文檔了https://help.sumologic.com/，以下衹是基本流程的闡述。

+ Add Collector

Sumologic會在目標機器上（liunx）安裝service，叫做collector，啓動服務就能上傳日志到sumologic云端，不管内網或者公共網都可以正常使用。配置有兩種，一種是local，一種是cloud的，local的collector必須在每個服務器單獨設置參數（我們通過chef來進行local設置），cloud則可以通過在sumologic在綫管理平臺進行遠程管理。配置如下：
```json
{
  "api.version":"v1",
  "source":{
    "name":"jboss-xxx",
    "category":"qa-xxx/jboss-xxx",
    "hostName":"qa-xxx.com",
    "automaticDateParsing":true,
    "multilineProcessingEnabled":true,
    "useAutolineMatching":true,
    "forceTimeZone":false,
    "timeZone":"America/Los_Angeles",
    "filters":[{
      "filterType":"Include",
      "name":"Error Include Filter",
      "regexp":"(?s).*(ERROR|EXCEPTION).*(?s)"
    }],
    "cutoffTimestamp":0,
    "encoding":"UTF-8",
    "pathExpression":"/opt/jboss/server/default/log/server.log",
    "blacklist":[],
    "sourceType":"LocalFile"
  }
}
```

+ Add App && Query

添加完collector后，collector服務就開始啪啪啪上傳日志到sumologic云了，此時在雲端管理平臺就能識別到這些collector了（one collector per server）。下一步就是對日志進行分析，我們要做的就是增加App或者自己寫Query。sumologic本身提供了apache啊，docker啊等等的app，可以很方便的配置進行分析，tomcat app就包括geo分析，異常分析，用戶分析等等，直接可以應用到tomcat的access log。如果是沒有提供的log或者是自定義的log，我們可以自己寫query來分析，query怎麽寫參考官網，語法類似于SQL+管道命令的結合。

+ Add To Dashboard

儅我們設置好要分析的App和Query后，就可以將這些設置放到一個dashboard裏面，方便查看。

+ Alert && Integration

此外，可以設置闕值和警報，并且可以集成到流行的chat軟件比如slack之類，方便維護人員監控維護。

Conclusion
---------------------
總之，這只是一個工具，具體工作還是要人來做的。比如我們自己要寫如何分析日志，獲取有用信息，以及我們自己要查看結果進行分析。所有事情沒有sumologic你也可以完成，所以sumologic的價值在於云設備存儲，不錯的查詢性能以及centralize日志。



