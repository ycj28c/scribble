---
layout: post
title: Upgrade Maven Project Dependency
disqus: y
share: y
categories: [Database]
tags: [Postgres, Performance]
---

這個系統已經超過10年了，不像新項目直接拿個新框架就上，老系統修修補補，再遷移一下十分費勁。如果升級像是Java版本還好，只要不是用什麽特殊技術，通常向下兼容。但是大項目Maven project龐大的Jars就沒這麽方便了，儅更新了一個jar A，那麽就得改jar B，改了jar B發現jar C也不行了，無窮無盡。這裏簡單闡述下更新的方法。

假設我們要從springBoot 1.1.12.RELEASE升級到springBoot 2.0.9.RELEASE，全部過程靠兩個工具，1是maven dependency tree（我用的intellij自帶插件），還有https://mvnrepository.com網站。  
1.在mvnrepository找到要升級的2.0.9.RELEASE的依賴，該網站提供了詳細了Compile Dependencies列表，可以知道這個Jar的以來，比如2.0.9.RELEASE，就依賴了

///TODO

English Version
---------------
//TODO

Reference
----------
1. [Circular Dependencies in Spring](https://www.baeldung.com/circular-dependencies-in-spring)  
2. [Spring 5 MVC + Hibernate 5 Example](https://howtodoinjava.com/spring5/webmvc/spring5-mvc-hibernate5-example/)  
